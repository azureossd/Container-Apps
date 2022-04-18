const express = require('express')
const app = express()
app.use(express.json({ type: 'application/json' }));
const request = require('request');

const port = process.env.APP_PORT || 5000;

const daprPort = process.env.DAPR_HTTP_PORT || 3500;
const daprUrl = `http://localhost:${daprPort}/v1.0`;

const topic = process.env.SB_TOPIC || "mytopic1";

const pubsub_name = process.env.PUBSUB_NAME|| "mypubsub1";

app.post('/publish', (req, res) => {
  const publishUrl = `${daprUrl}/publish/${pubsub_name}/${topic}`;

  request( { uri: publishUrl, method: 'POST', json: req.body } );  

  console.log("Publishing: ", req.body, " via ", publishUrl);
  
  res.sendStatus(200);
});

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`publisher app listening on port ${port}!`))