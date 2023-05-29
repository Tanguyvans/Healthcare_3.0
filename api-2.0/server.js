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

const ejs = require('ejs');
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

logger.level = 'debug';

function getUserInfo(req) {
  const token = req.cookies.token; // Récupérer le jeton JWT à partir du cookie

  if (token) {
    try {
      const decodedToken = jwt.verify(token, 'mysecretkey'); // Vérifier et décoder le jeton JWT

      const username = decodedToken.username; // Récupérer le nom d'utilisateur du jeton décodé
      const orgName = decodedToken.orgName; // Récupérer le nom de l'organisation du jeton décodé

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
  res.render('login');
});

app.post("/login", async (req, res) => {
  var { username, orgName } = req.body; 

  var token = jwt.sign({
      exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
      username: username,
      orgName: orgName
  }, 'mysecretkey');

  res.cookie("token", token);
  res.render('dashboard');
});

app.get("/dashboard", cookieJwtAuth, (req, res) => {
  res.render('dashboard');
});

app.get("/addSensor", cookieJwtAuth, (req, res) => {
  res.render('addSensor', { success: "none" });
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
    let message = await invoke.createSensor(args, username, orgName);

    res.render('addSensor', { success: "success" });

  } catch (error) {
    res.render('addSensor', { success: "failure" });
  }
});

app.get('/viewSensors', cookieJwtAuth, async function (req, res) {
  try {
      logger.debug('==================== QUERY BY CHAINCODE ==================');
      const {username, orgName} = getUserInfo(req);

      const sensorType = req.query.sensorType;
      const available = req.query.available;
      
      if(typeof available === 'undefined'){
        if(typeof sensorType === 'undefined'){
          var message = await query.queryAllSensors(username, orgName);
        }else if(sensorType === 'All'){
          var message = await query.queryAllSensors(username, orgName);
        }else {
          var message = await query.querySensorsType(sensorType, username, orgName);
        }  
      }else if(available === 'true'){
        if(typeof sensorType === 'undefined'){
          var message = await query.queryAllSensorsAvailable(username, orgName);
        }else if(sensorType === 'All'){
          var message = await query.queryAllSensorsAvailable(username, orgName);
        }else {
          var message = await query.querySensorsTypeAvailable(sensorType, username, orgName);
        }
      }else {
        var message = await query.queryAllSensors(username, orgName);
      }

      console.log(message);

      res.render('viewSensors', { sensors: message });
  } catch (error) {
      const response_payload = {
          result: null,
          error: error.name,
          errorData: error.message
      }
      res.send(response_payload)
  }
});

app.listen(PORT, () => {
  console.log(`Example app listening at http://localhost:${PORT}`);
});