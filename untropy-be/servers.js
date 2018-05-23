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
  const receivedServer = createElement('server', req.query);
  if (receivedServer) {
    servers.push(receivedServer);
    res.status(201).send(receivedServer);
  } else {
    res.status(400).send();
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
  const serverIndex = getIndexById(req.params.id, servers);
  if (serverIndex !== -1) {
    servers.splice(serverIndex, 1);
    res.status(204).send();
  } else {
    res.status(404).send();
  }
});

module.exports = serversRouter;
