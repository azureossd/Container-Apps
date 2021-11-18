const express = require('express')
const app = express()

const port = process.env.APP_PORT || 80

app.get('/', (req, res) => {
	res.send("Docker container for GitHub actions sample was successfully pulled");
  //res.sendStatus(200);
});

app.listen(port, () => console.log(`App listening on port ${port}!`))