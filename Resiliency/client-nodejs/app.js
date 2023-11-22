const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())
const http = require('http')

const port = process.env.APP_PORT || 4000

var outboundrequest = require('request');
backendappid = process.env.backendappid || 'resiliencyapp'

app.get('/retrycount', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/retrycount";

	var message = "Response returned by the backend API: ";

	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "A failure occurred";
	}
	
	console.log(message + response);
	
	res.send(JSON.stringify(response));
})


app.get('/resetretrycount', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/resetretrycount";

	var message = "Response returned by the backend API: ";

	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "failure";
	}
	
	console.log(message + response);
	
	res.send(JSON.stringify(response));
})

app.get('/httperrortest', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/httperrortest";

	var message = "Response returned by the backend API: ";

	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "failure";
	}
	
	console.log(message + response);
	
	res.send(JSON.stringify(response));
})

app.get('/timeouttest', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/timeouttest";

	var message = "Response returned by the backend API: ";

	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "failure";
	}
	
	console.log(message + response);
	
	res.send(JSON.stringify(response));
})

app.get('/responseheadertest', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/responseheadertest";

	var message = "Response body returned by the backend API: ";

	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "failure";
	}
	
	console.log(response);
	
	res.send(JSON.stringify(response));
})

app.get('/circuitbreakertest', async (req, res) => {
	res.setHeader('Content-Type', 'application/json');
	
	var backendDaprInvokeUrl = "http://localhost:3500/v1.0/invoke/" + backendappid + "/method/api/circuitbreakertest";

	var message = "Response returned by the backend API: ";
	
	response = await outboundrequestandresponse(backendDaprInvokeUrl);
	
	if (response == null || response == ''){
		response = "failure";
	}
	
	console.log(message + response);
	
	res.send(JSON.stringify(response));
})

app.listen(port, () => console.log(`App listening on port ${port}!`))

function outboundrequestandresponse (url) {
    return new Promise((resolve, reject) => {
	    outboundrequest.get(url, (error, response, body) => {
		    if(error) {
			    console.log(error);
				reject(body);
		    }
			else {
				if (response.headers['food'] != null)
					console.log('Food response header value: ' + response.headers['food']);
				else
					console.log('No Food response header.');

				resolve(body);
			}
		});
	});
}

function outboundrequestwithheaderandresponse (url) {
    return new Promise((resolve, reject) => {
	outboundrequest({url: url, headers: {'triggerfaiure': 'true'}}, (error, response, body) => {
		    if(error) {
			    console.log(error);
				reject(body);
		    }
			else {
				console.log('header: ' + JSON.stringify(outboundrequest.headers));
				resolve(body, response);
			}
		});
	});
}