const express = require('express');
var mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/untropy');
var db = mongoose.connection;

var checksSchema = mongoose.Schema({
	name: String,
	position: String,
	level: String,
	description: String
});

var checks = mongoose.model("checks", checksSchema);

const checksRouter = express.Router();

// Get all checks
checksRouter.get('/', (req, res, next) => {
  checks.find(function(err, response) {
  if (err) throw err;

	res.send(response);
  });
});


// Get a single check
checksRouter.get('/:id', (req, res, next) => {
  const checkId = Number(req.params.id);
  
  checks.find({position:checkId},function(err, response) {
	if (err) throw err;
	
	res.send(response);
  });
});

module.exports = checksRouter;
