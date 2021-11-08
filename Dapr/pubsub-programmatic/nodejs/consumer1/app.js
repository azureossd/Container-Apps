const express = require('express')
const app = express()
app.use(express.json({ type: 'application/*+json' }));

const port = process.env.APP_PORT || 3000

const topic = process.env.SB_TOPIC || "mytopic1";

const pubsub_name = process.env.PUBSUB_NAME|| "mypubsub1";

//subscribes to the topic(s), when the app starts
app.get('/dapr/subscribe', (req, res) => {
    res.json([
        {
            pubsubname: pubsub_name,
            topic: topic,
            route: "myroute1"
        }
    ]);
})


//for each message that is in the topic(s) that this route is subscribed to, execute this route method 
app.post('/myroute1', (req, res) => {
	console.log(`consumer1 is consuming a message: ` + JSON.stringify(req.body.data));
    res.sendStatus(200);
});

app.get('/', (req, res) => {
    res.sendStatus(200);
});

app.listen(port, () => console.log(`consumer1 app listening on port ${port}!`))