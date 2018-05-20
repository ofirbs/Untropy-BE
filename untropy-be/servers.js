const express = require('express');

const servers = ['server1','server2','server3'];

const serversRouter = express.Router();

// Get all servers
serversRouter.get('/', (req, res, next) => {
  res.send(servers);
});

// Get a single server
serversRouter.get('/:id', (req, res, next) => {
  const server = getElementById(req.params.id, server);
  if (server) {
    res.send(server);
  } else {
    res.status(404).send();
  }
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
