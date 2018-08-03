const express = require('express');
var mongoose = require('mongoose');
var Client = require('ssh2').Client;
var cron = require('node-schedule');

mongoose.connect('mongodb://localhost:27017/untropy');
var db = mongoose.connection;

var serversSchema = mongoose.Schema({
	name: String,
	ip: String,
	checks: String,
	time: Date,
	result: String,
	status: String
	},
{
    versionKey: false
});

var servers = mongoose.model("servers", serversSchema);

const serversRouter = express.Router();

var getResultFromServer = function(hostname, checkList) {
  console.log('running on ' + hostname)
  var conn = new Client();
  conn.on('ready', function() {
  console.log('Client :: ready');
  conn.exec('curl -s https://raw.githubusercontent.com/ofirbs/Untropy-BE/master/procedure.sh | bash /dev/stdin '+checkList, function(err, stream) {
    if (err) throw err;
    stream.on('close', function(code, signal) {
      console.log('Stream :: close :: code: ' + code + ', signal: ' + signal);
      conn.end();
    }).on('data', function(data) {
      
      var dataArr = data.toString().split(',');
      servers.findOneAndUpdate({name: hostname}, {result: dataArr[0], time: Date.now(), status: dataArr[1]}, function(err, response) {
        console.log("updated server" + hostname)
      });
    }).stderr.on('data', function(data) {
      console.log('STDERR: ' + data);
    });
  });
}).connect({
  host: hostname,
  port: 22,
  username: 'root',
  readyTimeout: 99999,
  privateKey: require('fs').readFileSync('../\../\../\Users/\Administrator/\Documents/\priv-key.ppk')
});
}


// ssh test
serversRouter.get('/ssh', (req, res, next) => {
  let serversArray='a'
  servers.find(function(err, response) {
    serversArray=response
  });

  setTimeout(function() {
    for (var i = 0; i < serversArray.length ; i++) {
      console.log("running on server " + i + " :" + serversArray[i].name)
      getResultFromServer(serversArray[i].name, serversArray[i].checks)
      var waitTill = new Date(new Date().getTime() + 2000);
      while(waitTill > new Date()){}
    }
}, 2000);

  res.send("OK")
});

//cron.scheduleJob('* */30 * * * *', function(){
//  console.log("running the cron at: " + Date.now())
//  let serversArray='a'
//   servers.find(function(err, response) {
//     serversArray=response
//   });

//   setTimeout(function() {
//     for (var i = 0; i < serversArray.length ; i++) {
//       console.log("running on server " + i + " :" + serversArray[i].name)
//       getResultFromServer(serversArray[i].name, serversArray[i].checks)
//       var waitTill = new Date(new Date().getTime() + 2000);
//       while(waitTill > new Date()){}
//     }
// }, 2000);

// });

// Get all servers
serversRouter.get('/', (req, res, next) => {
  servers.find(function(err, response) {
  if (err) throw err;

	res.send(response);
  });});

// Group servers by health status
serversRouter.get('/health', (req, res, next) => {
  servers.aggregate([
        {
            $group: {
                _id : "$status",
                count: {$sum: 1}
            }
        }
    ], function (err, result) {
        if (err) throw err;
        res.send(result);
    });
});

serversRouter.get('/querya/:health/:time', (req, res, next) => {
  var healthStatus = req.params.health;
  var timeToCheck = new Date( Date.now() - req.params.time * 1000 * 60 ); 
  
  servers.find({status: healthStatus, time : { $gte: timeToCheck}}, function(err, response) {
  if (err) throw err;

  res.send(response);
  });
});

serversRouter.get('/queryb/:name/:ok/:warning/:critical', (req, res, next) => {
  servers.find({"name" : { '$regex' : req.params.name, '$options' : 'i' }}, function(err, response) {
  if (err) throw err;

  var dataArr = [];
  var okNum = 0;
  var warningNum = 0;
  var criticalNum = 0;

  for (var i = 0; i < response.length ; i++) {
    for (var j = 0; j < response[i].result.length ; j++) {
      if (response[i].result[j] == 2)
        okNum++;
      else if (response[i].result[j] == 3)
        warningNum++;
      else if (response[i].result[j] == 4)
        criticalNum++;
    }
    if (okNum >= req.params.ok && warningNum >= req.params.warning && criticalNum >= req.params.critical)
      dataArr.push(response[i]);
    okNum = 0;
    warningNum = 0;
    criticalNum = 0;
  }  
  console.log(dataArr);
  res.send(dataArr);
  });
});



// Get a single server
serversRouter.get('/:id', (req, res, next) => {
  const serverId = req.params.id;
  
  servers.find({"_id" : serverId},function(err, response) {
	if (err) throw err;
	
	res.send(response);
  });
});


// Add a server
serversRouter.post('/', (req, res, next) => {
  var serverInfo = req.body;
  console.log(serverInfo)
  console.log("server name: " + serverInfo.name)
  console.log("server ip: " + serverInfo.ip)
  console.log("server checks: " + serverInfo.checks)

  if(!serverInfo.name || !serverInfo.ip || !serverInfo.checks){
      res.send("Sorry, you provided worng info");
   } 
   else {
      var newServer = new servers({
        name: serverInfo.name,
        ip: serverInfo.ip,
        checks: serverInfo.checks,
		    time: Date.now(), 
		    result: "1111111111111111111111111111111111111111111111111",
		    status: "unknown"
      });
		
      newServer.save(function(err, servers){
         if(err)
            res.send("Database error");
         else
            res.send("success");
      });

      getResultFromServer(serverInfo.name, serverInfo.checks)
	}
});

// Update a server
serversRouter.put('/:id', (req, res, next) => {
   servers.findByIdAndUpdate(req.params.id, req.body, function(err, response){
      if(err) res.json({message: "Error in updating server with id " + req.params.id});
      res.send("success");
   });
});

// Delete a single server
serversRouter.delete('/:id', (req, res, next) => {
  const serverId = req.params.id;
  servers.remove({"_id" : serverId},function(err, response) {
	if (err) throw err;
	res.send(response);
  });
});

module.exports = serversRouter;
