const express = require('express');
var mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/untropy');
var db = mongoose.connection;

var locationsSchema = mongoose.Schema({
	name: String,
	longtitude: String,
	latitude: String,
});

var locations = mongoose.model("locations", locationsSchema);

const locationsRouter = express.Router();

var locationsToExp;

// Get all locations
locationsRouter.get('/', (req, res, next) => {
  locations.find(function(err, response) {
  if (err) console.log(err);
	res.send(response);
  });
});


function getLocations(){
	//console.log("got");
	locations.find({}).lean().exec(function (err, docs) {
	//console.log("got");
	//locationsToExp = docs;
	return docs;
	//console.log(locationsToExp);	// returns json
    });
}
getLocations();
setInterval(getLocations, 2*1000);

module.exports = {
    router : locationsRouter,
    locations : function(){
	getLocations();
}
}