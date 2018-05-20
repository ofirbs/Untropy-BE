const express = require('express');

const checks = ['11111','10110','11001'];

const checksRouter = express.Router();

// Get all checks
checksRouter.get('/', (req, res, next) => {
  res.send(checks);
});

// Get a single check
checksRouter.get('/:id', (req, res, next) => {
  const foundCheck = getElementById(req.params.id, checks);
  if (foundCheck) {
    res.send(foundCheck);
  } else {
    res.status(404).send();
  }
});

// Update an check
checksRouter.put('/:id', (req, res, next) => {
  const checkIndex = getIndexById(req.params.id, checks);
  if (checkIndex !== -1) {
    updateElement(req.params.id, req.query, checks);
    res.send(checks[checkIndex]);
  } else {
    res.status(404).send();
  }
});

// Create an check
checksRouter.post('/', (req, res, next) => {
  const receivedCheck = createElement('checks', req.query);
  if (receivedCheck) {
    checks.push(receivedCheck);
    res.status(201).send(receivedCheck);
  } else {
    res.status(400).send();
  }
});

// Delete an check
checksRouter.delete('/:id', (req, res, next) => {
  const checkIndex = getIndexById(req.params.id, checks);
  if (checkIndex !== -1) {
    checks.splice(checkIndex, 1);
    res.status(204).send();
  } else {
    res.status(404).send();
  }
});

module.exports = checksRouter;
