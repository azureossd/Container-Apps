const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 4000

app.get('/biscuits', (req, res) => {
  console.log(`/biscuits route was requested`)
  res.send("Mmmm, biscuits. From backendapp1.");
});

app.get('/donuts/', (req, res) => {
  console.log(`/donuts/ route was requested`)
  res.send("mmm, donuts. From backendapp1.");
});

app.get('/donuts1/', (req, res) => {
  console.log(`/donuts1/ route was requested`)
  res.send("mmm, donuts1. From backendapp1.");
});

app.get('/donuts/maple', (req, res) => {
  console.log(`/donuts/maple route was requested`)
  res.send("Maple donuts. From backendapp1.");
});

app.get('/donuts/glazed', (req, res) => {
  console.log(`/donuts/glazed route was requested`)
  res.send("Glazed donuts. From backendapp1.");
});

app.get('/donuts/maple/bacon', (req, res) => {
  console.log(`/donuts/maple/bacon route was requested`)
  res.send("Maple bacon donuts. From backendapp1.");
});

app.get('/', (req, res) => {
  console.log(`/ route was requested`)
  res.send("Welcome to backendapp1.");
});

app.listen(port, () => console.log(`App listening on port ${port}!`))