const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 5000

const daprPort = process.env.DAPR_HTTP_PORT || 3500;

var outboundrequest = require('request');

//normal (non-Dapr) http route, which in turn invokes the Dapr API route to get the value of a key from the configured state store
app.get('/readstatestore', async (req, res) => {
    console.log('executing readstatestore method')
	res.setHeader('Content-Type', 'application/json');
	var daprUrl = `http://localhost:${daprPort}/v1.0/state/mystatestore/fakekey1`;

	const response = await outboundGetResponse(daprUrl);
	
	//returns the value currently stored in the fakekey1 key
	res.send('Value returned from statestore: ' + JSON.stringify(response));
	//res.status(200).send()
})

//normal (non-Dapr) http route, which in turn invokes the Dapr API route to save to the configured state store
app.get('/writestatestore', async (req, res) => {
    console.log('executing writestatestore method')
	res.setHeader('Content-Type', 'application/json');
	var options = {
		url: `http://localhost:${daprPort}/v1.0/state/mystatestore`,
		method: "POST",
		json: true,
		body: [{'key':'fakekey1', 'value': 'fakevalue ' + Date.now()}]
	};

	//This will set the value of the fakekey1 key to 'fakevalue ' + Date.now()' in the configured state store
	outboundrequest.post(options, (err, res, body) => {
		if (err) {
			return console.log(err);
		}
		console.log('Writing ' + JSON.stringify(options.body) + ' to state store.')
	});
	
	res.send('Writing ' + JSON.stringify(options.body) + ' to state store.');
	//res.status(200).send()
})

function outboundGetResponse (url, headers) {
    return new Promise((resolve, reject) => {
	    outboundrequest.get(url, headers, (error, response, body) => {
		    if(error) {
			    console.log(error);
				reject(body);
		    }
			else {
				console.log('State store value ' + body);
				resolve(body);
			}
		});
	});
}

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`App listening on port ${port}!`))