const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 5000

//normal (non-Dapr) http route
app.get('/backendpoint', (req, res) => {
    console.log('executing backendpoint method')
	res.setHeader('Content-Type', 'application/json');
	res.send(JSON.stringify({key:"This is the response from the backendpoint method"}));
	//res.status(200).send()
})

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`App listening on port ${port}!`))