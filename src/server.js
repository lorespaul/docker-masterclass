const express = require('express')
const bodyParser = require('body-parser')
const database = require('./db')()
const { execFile } = require('child_process')

const host = '0.0.0.0'
const port = 8080

const app = express()

app.use(bodyParser.json())

app.get('/greet', (_req, res) => {
  const result = `Hello ${process.env.WHO_TO_GREET}!`
  console.log(result)
  res.send(`${result}\n`)
})

app.get('/not_greet', (_req, res) => {
  const result = `Good by ${process.env.WHO_TO_NOT_GREET}`
  console.log(result)
  res.send(`${result}\n`)
})

app.get('/getenv/:envname', (req, res) => {
  const result = process.env[req.params.envname]
  console.log(result)
  res.send(`${result}\n`)
})

app.get('/db_users', async (_req, res) => {
  try{
    const result = await database.simpleGet()
    console.log(result)
    res.json(result)
  } catch(e){
    console.error(e)
    res.json({})
  }
})

app.post('/exec_process', async (req, res) => {
  const executable = req.body.executable || 'src/native/mylib'
  const shell = req.body.shell || '/bin/sh'
  execFile(executable, { shell }, (error, stdout, stderr) => {
    if(error){
      console.log(error, '---', stderr)
      res.status(500).json({error: error})
      return
    }
    console.log(stdout)
    res.send(stdout)
  })
})

app.listen(port, host, () => {
  console.log(`Running on http://${host}:${port}`)
})