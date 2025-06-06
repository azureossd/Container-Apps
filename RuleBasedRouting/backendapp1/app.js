const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 4000

app.get('/biscuits', (req, res) => {
  console.log(`/biscuits route was requested`)
  res.send("Mmmm, biscuits. From backendapp1.");
});

app.get('/donuts/maple', (req, res) => {
  console.log(`/donuts/maple route was requested`)
  res.send("Maple donuts. From backendapp1.");
});

app.get('/', (req, res) => {
  console.log(`/donuts/maple route was requested`)
  res.send("Welcome to backendapp1.");
});

app.listen(port, () => console.log(`App listening on port ${port}!`))