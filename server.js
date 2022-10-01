const express = require('express')

const host = '0.0.0.0'
const port = 8080

const app = express()

app.get('/greet', (_req, res) => {
  const result = `Hello ${process.env.WHO_TO_GREET}!`
  console.log(result)
  res.send(`${result}\n`)
});

app.get('/not_greet', (_req, res) => {
  const result = `Good by ${process.env.WHO_TO_NOT_GREET}`
  console.log(result)
  res.send(`${result}\n`)
});

app.get('/getenv/:envname', (req, res) => {
  const result = process.env[req.params.envname]
  console.log(result)
  res.send(`${result}\n`)
});

app.listen(port, host, () => {
  console.log(`Running on http://${host}:${port}`)
});