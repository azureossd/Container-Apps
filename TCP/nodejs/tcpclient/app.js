const express = require('express')
const app = express()

const port = process.env.APP_PORT || 4000

app.get('/', (req, res) => {  
  res.sendStatus(200);
});

app.listen(port, () => console.log(`App listening on port ${port}!`))