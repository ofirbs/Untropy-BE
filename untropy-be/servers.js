const express = require('express');
var mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/untropy');
var db = mongoose.connection;

var serversSchema = mongoose.Schema({
	name: String,
	ip: String,
	checks: String,
});

var servers = mongoose.model("servers", serversSchema);


const serversRouter = express.Router();

// Get all servers
serversRouter.get('/', (req, res, next) => {
  servers.find(function(err, response) {
  if (err) throw err;

	res.send(response);
  });});

  
// Get a single server
serversRouter.get('/:id', (req, res, next) => {
  const serverId = req.params.id;
  
  servers.find({"_id" : serverId},function(err, response) {
	if (err) throw err;
	
	res.send(response);
  });
});

// Create a server
serversRouter.post('/', (req, res, next) => {
  var serverInfo = req.body;
  //console.log(serverInfo.name);
  //res.send("OK");
  if(!serverInfo.name || !serverInfo.ip || !serverInfo.checks){
      res.send("Sorry, you provided worng info");
   } 
   else {
      var newServer = new servers({
        name: serverInfo.name,
        ip: serverInfo.ip,
        checks: serverInfo.checks
      });
		
      newServer.save(function(err, servers){
         if(err)
            res.send("Database error");
         else
            res.send("success");
      });
	}
});

// Update a server
serversRouter.put('/:id', (req, res, next) => {
  const serverIndex = getIndexById(req.params.id, servers);
  if (serverIndex !== -1) {
    updateElement(req.params.id, req.query, servers);
    res.send(servers[serverIndex]);
  } else {
    res.status(404).send();
  }
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
