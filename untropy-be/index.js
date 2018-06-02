var express = require('express');
var app = express();
var bodyParser = require('body-parser');


const PORT = process.env.PORT || 80;

app.use(bodyParser.urlencoded({extended: true}));
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
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



app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is listening on ${PORT}`);
});
