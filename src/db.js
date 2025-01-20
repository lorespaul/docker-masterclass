const enabled = process.env.PG_ENABLED || false
const host = process.env.PG_HOST || 'pg-server'
const port = process.env.PG_PORT || 5432
const user = process.env.PG_USER || 'root'
const pass = process.env.PG_PASS || 'betacom'
const database = process.env.PG_DB || 'example'

let sql
const connect = () => {
  const postgres = require('postgres')
  sql = postgres({
    host: host,
    port: port,
    database: database,
    username: user,
    password: pass
  })
}

if(enabled){
  connect()
}

const Database = () => {
  return {
    isEnabled: () => {
      return !!sql
    },
    simpleSelect: async () => {
      if(sql){
        const result = await sql`
          SELECT * FROM users      
        `
        return result
      }
      return { error: 'No database connected' }
    },
    simpleInsert: async (user) => {
      if(sql){
        const [result] = await sql`
          INSERT INTO users ${
            sql(user, 'email', 'username')
          }
          returning *;
        `
        return result
      }
      return { error: 'No database connected' }
    }
  }
}

module.exports = Database