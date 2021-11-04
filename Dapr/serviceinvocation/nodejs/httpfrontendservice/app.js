const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())

const port = process.env.APP_PORT || 4000

var outboundrequest = require('request');

//normal (non-Dapr) http route
app.get('/frontendpoint', async (req, res) => {
    console.log('executing frontendpoint method')
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/backendapp/method/backendpoint";

	// This app, when registered with Dapr, will make a call to another Dapr-registered app by using the Dapr Invoke API rather than a direct request to the other app.
	// This way, the request takes advantages of the handling that Dapr offers.
	const response = await backendresponse(backendDaprInvokeUrl);
	res.send(JSON.stringify(response));
	//res.status(200).send()
})

function backendresponse (url) {
    return new Promise((resolve, reject) => {
	    outboundrequest.get(url, (error, response, body) => {
		    if(error) {
			    console.log(error);
				reject(body);
		    }
			else {
				console.log('Response from outbound request to backendpoint method: ' + body);
				resolve(body);
			}
		});
	});
}

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`App listening on port ${port}!`))