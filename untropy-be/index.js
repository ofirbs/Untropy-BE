var express = require('express');
var app = express();
var bodyParser = require('body-parser');


const PORT = process.env.PORT || 3000;

app.use(bodyParser.urlencoded({extended: true}));

app.get('/', function(req, res){
   res.send("Hello world2!");
});


// Import and mount the expressionsRouter
const serversRouter = require('./servers.js');
app.use('/servers', serversRouter);

const checksRouter = require('./checks.js');
app.use('/checks', checksRouter);

const proceduresRouter = require('./procedures.js');
app.use('/procedures', proceduresRouter);



app.listen(PORT, () => {
  console.log(`Server is listening on ${PORT}`);
});
