const express = require("express");
const { Client } = require("pg");
const jwt = require("jsonwebtoken"); 
const identity = require("@azure/identity");
const credential = new identity.WorkloadIdentityCredential();

require("dotenv").config();
 

const app = express();

const port = process.env.PORT || 3000;
const host = process.env.PG_HOST;
const database = process.env.PG_DATABASE;
const username = process.env.PG_USERNAME;

async function getAccessToken() {
  try {
    const accessToken = await credential.getToken(
      "https://ossrdbms-aad.database.windows.net/.default"
    );
    const decodedToken = jwt.decode(accessToken.token, { complete: true });
    console.log(decodedToken);
    return accessToken.token;
  } catch (err) {
    console.error("Access Token Error", err);
    return err;
  }
}

app.get("/healthCheck", async (req, res) => {
  try {
    const dbResponse = await connectToPostgres();
    res.json(dbResponse);
  } catch (err) {
    res.status(500).send(err);
  }
});

async function connectToPostgres() {
  try {
    const token = await getAccessToken();
    const client = new Client({
      host: host,
      database: database,
      user: username,
      password: token,
      port: 5432,
      ssl: {
        rejectUnauthorized: true,
      },
    });
    await client.connect();

    const response = await client.query("SELECT version();");
    console.log(response.rows);

    await client.end();

    return response.rows;
  } catch (err) {
    console.error("Error connecting to PostgreSQL", err);
    throw err;
  }
}
 

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

 