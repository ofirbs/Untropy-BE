const express = require('express');
var mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/untropy');
var db = mongoose.connection;

var procedureSchema = mongoose.Schema({
	server: String,
	time: Date,
	result: String,
	status: String
});

var procedures = mongoose.model("procedures", procedureSchema);

const proceduresRouter = express.Router();

// Get all procedures
proceduresRouter.get('/', (req, res, next) => {
  procedures.find(function(err, response) {
  if (err) console.log(err);

	res.send(response);
  });
});


// Get a single procedure
proceduresRouter.get('/:id', (req, res, next) => {
  const serverId = req.params.id;
  
  procedures.find({"_id" : serverId},function(err, response) {
	if (err) console.log(err);
	
	res.send(response);
  });
});

module.exports = proceduresRouter;
