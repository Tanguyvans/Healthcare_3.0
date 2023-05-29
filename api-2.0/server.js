const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const express = require("express");
const cookieParser = require("cookie-parser");
const path = require("path");
const jwt = require('jsonwebtoken');
const app = express();
const PORT =5000;

const constants = require('./config/constants.json')
const { cookieJwtAuth } = require("./src/middleware/cookieJwtAuth");

const helper = require('./app/helper')
const invoke = require('./app/invoke')
const qscc = require('./app/qscc')
const query = require('./app/query')
const del = require('./app/delete')
const update = require('./app/update')

logger.level = 'debug';

function getUserInfo(req) {
  const token = req.cookies.token; // Récupérer le jeton JWT à partir du cookie

  if (token) {
    try {
      const decodedToken = jwt.verify(token, 'mysecretkey'); // Vérifier et décoder le jeton JWT

      const username = decodedToken.username; // Récupérer le nom d'utilisateur du jeton décodé
      const orgName = decodedToken.orgName; // Récupérer le nom de l'organisation du jeton décodé

      console.log(username, orgName)
      return { username, orgName };
    } catch (error) {
      // Gérer les erreurs de vérification du jeton JWT
      console.error(error);
    }
  }

  return null; // Retourner null si le jeton est absent ou invalide
}

app.use(
  express.urlencoded({
    extended: true,
  })
);
app.use(cookieParser());

app.get("/", (req, res) => {
  res.sendFile(__dirname + '/views/login.html');
});

app.get("/dashboard", cookieJwtAuth, (req, res) => {
  res.sendFile(__dirname + '/views/dashboard.html');
});

app.post("/login", async (req, res) => {
    var { username, orgName } = req.body; 

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName
    }, 'mysecretkey');

    res.cookie("token", token);

    return res.redirect("/dashboard");
});

app.get("/addSensor", cookieJwtAuth, (req, res) => {
  res.sendFile(__dirname + '/views/addSensor.ejs');
});

app.post('/addSensor', cookieJwtAuth, async function (req, res) {
  try {
    logger.debug('==================== INVOKE ON CHAINCODE ==================');
    var { sensorId, sensorType, patient } = req.body;
    if (!sensorId || !sensorType || !patient) {
        res.status(400).json({ error: 'Paramètres manquants' });
        return;
    }
    var args = [sensorId, sensorType, patient];
    logger.debug('args  : ' + args);

    const {username, orgName} = getUserInfo(req);
    console.log(username, orgName);

    let message = await invoke.createSensor(args, username, orgName);
    console.log(`message result is : ${message}`)

    res.redirect(`/addSensor?result=${encodeURIComponent(message)}`);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur lors de l\'ajout du capteur' });
  }
});

app.listen(PORT, () => {
  console.log(`Example app listening at http://localhost:${PORT}`);
});