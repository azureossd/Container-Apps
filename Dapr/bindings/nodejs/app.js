const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 5000

var outboundrequest = require('request');

const options = {
url: "http://localhost:3500/v1.0/bindings/mybindingforoutput",
method: "POST",
json: true
};

//The name of this controller matches the metadata name of a Dapr binding component
//Dapr will automatically make a request to this route when it detects a message in the provider you specify
app.post('/mybindingforinput', (req, res) => {
	res.setHeader('Content-Type', 'application/json');
    console.log('/mybindingforinput controller was triggered via Dapr input binding. Message data: ' + JSON.stringify(req.body))
	
	// When the mybindingforinput binding component is triggered, this route will be invoked. In turn, this route will make a request to the Dapr binding route for mybindingforoutput, which will invoke the specified output binding.

    options.body = { data: JSON.stringify(req.body), operation: 'create'};

	outboundrequest.post(options, (err, res, body) => {
	if (err) {
		return console.log(err);
	}
	console.log('mybindingforinput route made an outbound request to Dapr output binding endpoint for mybindingforoutput');
	});
	
    res.status(200).send()
})

//Non-Dapr http route.
//This route will make a request to the Dapr binding route for mybindingforoutput, which will invoke the specified output binding. You can make a direct request to this route if you want to test the output binding without having to first trigger the input binding.
app.get('/myroute', (req, res) => {
    console.log('executing myroute');
	
	options.body = { data: {key: 'MyRoute method wrote to the output binding at ' + Date.now()}, operation: 'create'};

	outboundrequest.post(options, (err, res, body) => {

	if (err) {
		return console.log(err);
	}

	console.log('MyRoute made an outbound request to http://localhost:3500/v1.0/bindings/mybindingforoutput to use the output binding')
	});
	
	res.status(200).send()
})

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`Binding app listening on port ${port}!`))