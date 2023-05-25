const express = require('express');
const path = require('path');

const app = express();
const port = 3000;

// sendFile will go here
app.get('/wattx', function(req, res) {
  res.sendFile(path.join(__dirname, '/wattx.html'));
});

app.get('/exchange', function(req, res) {
  res.sendFile(path.join(__dirname, '/TokenExchange.html'));
})

app.get('/inr', function(req, res) {
  res.sendFile(path.join(__dirname, '/inr.html'));
})

app.listen(port);
console.log('Server started at http://localhost:' + port);
