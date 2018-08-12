var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var http = require('http');
//old - var server = http.createServer(app);
var server = require('http').createServer(app);
var io = require('socket.io').listen(server, {log:false, origins:'*:*'});


io.origins('*:*');

const PORT = process.env.PORT || 80;

app.use(bodyParser.urlencoded({extended: true}));
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*" );
  res.header('Access-Control-Allow-Credentials', true);
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE");
  next();
});


app.get('/', function(req, res){
   res.send("Please use /servers, /checks, /procedures rest APIs");
});


// Import and mount the routers
const serversRouter = require('./servers.js');
app.use('/servers', serversRouter);

const checksRouter = require('./checks.js');
app.use('/checks', checksRouter);

const proceduresRouter = require('./procedures.js');
app.use('/procedures', proceduresRouter);

const locationsRouter = require('./map.js');
app.use('/locations', locationsRouter.router);



//socket io
io.on('connection', function(socket){
  socket.emit('test', {hello: 'world'});
  //socket.emit('locations', locationsRouter.locations);
  socket.on('event', function(data) {
    console.log(data);
  })
  socket.on('locations', function() {
	  socket.emit('reply', locationsRouter.locations);
  })
    socket.on('isOk', function() {
	  socket.emit('serverOk', {server: 'server is ok'});
  })
});

//instead of app.listen
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is listening on ${PORT}`);
});
