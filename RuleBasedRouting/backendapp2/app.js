const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 4000

app.get('/gravy', (req, res) => {
  console.log(`/gravy route was requested`)
  res.send("Gravy for the biscuits. From backendapp2.");
});


app.get('/', (req, res) => {
  console.log(`/ route was requested`)
  res.send("Welcome to backendapp2.");
});

app.listen(port, () => console.log(`App listening on port ${port}!`))