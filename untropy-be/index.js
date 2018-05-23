var express = require('express');
var app = express();

const PORT = process.env.PORT || 3000;

app.get('/', function(req, res){
   res.send("Hello world2!");
});


// Import and mount the expressionsRouter
const serversRouter = require('./servers.js');
app.use('/servers', serversRouter);

const checksRouter = require('./checks.js');
app.use('/checks', checksRouter);



app.listen(PORT, () => {
  console.log(`Server is listening on ${PORT}`);
});
