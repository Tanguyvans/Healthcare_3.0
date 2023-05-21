'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const bodyParser = require('body-parser');
const http = require('http')
const util = require('util');
const express = require('express')
const app = express();
const expressJWT = require('express-jwt');
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const cors = require('cors');
const constants = require('./config/constants.json')

const host = process.env.HOST || constants.host;
const port = process.env.PORT || constants.port;

const helper = require('./app/helper')
const invoke = require('./app/invoke')
const qscc = require('./app/qscc')
const query = require('./app/query')
const del = require('./app/delete')
const update = require('./app/update')

app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));
// set secret variable
app.set('secret', 'thisismysecret');
app.use(expressJWT({
    secret: 'thisismysecret'
}).unless({
    path: ['/','/users','/sensorCreateCapsule']
}));
app.use(bearerToken());

logger.level = 'debug';

app.use((req, res, next) => {
    logger.debug('New req for %s', req.originalUrl);
    if ( req.originalUrl === '/' || req.originalUrl.indexOf('/users') >= 0 || req.originalUrl.indexOf('/sensorCreateCapsule') >= 0) {
        return next();
    }
    var token = req.token;
    jwt.verify(token, app.get('secret'), (err, decoded) => {
        if (err) {
            console.log(`Error ================:${err}`)
            res.send({
                success: false,
                message: 'Failed to authenticate token. Make sure to include the ' +
                    'token returned from /users call in the authorization header ' +
                    ' as a Bearer token'
            });
            return;
        } else {
            req.username = decoded.username;
            req.orgname = decoded.orgName;
            logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
            return next();
        }
    });
});

var server = http.createServer(app).listen(port, function () { console.log(`Server started on ${port}`) });
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
    var response = {
        success: false,
        message: field + ' field is missing or Invalid in the request'
    };
    return response;
}

app.get('/', function(req, res) {
    res.sendFile(__dirname + '/app/views/login.html');
  });

// Register and enroll user
app.post('/users', async function (req, res) {
    var username = req.body.username;
    var orgName = req.body.orgName;
    logger.debug('End point : /users');
    logger.debug('User name : ' + username);
    logger.debug('Org name  : ' + orgName);
    if (!username) {
        res.json(getErrorMessage('\'username\''));
        return;
    }
    if (!orgName) {
        res.json(getErrorMessage('\'orgName\''));
        return;
    }

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName
    }, app.get('secret'));

    let response = await helper.getRegisteredUser(username, orgName, true);
    console.log('test');
    console.log(response);
    logger.debug('-- returned from registering the username %s for organization %s', username, orgName);
    if (response && typeof response !== 'string') {
        logger.debug('Successfully registered the username %s for organization %s', username, orgName);
        response.token = token;
        res.json(response);
        console.log(token, response);
    } else {
        logger.debug('Failed to register the username %s for organization %s with::%s', username, orgName, response);
        res.json({ success: false, message: response });
    }

});

// Using the sensor
app.post('/createSensor', async function (req, res) {
    try {
        logger.debug('==================== INVOKE ON CHAINCODE ==================');
        var { sensorId, sensorType, patient } = req.body;
        if (!sensorId || !sensorType || !patient) {
            res.status(400).json({ error: 'Paramètres manquants' });
            return;
        }
        var args = [sensorId, sensorType, patient];
        logger.debug('args  : ' + args);


        let message = await invoke.createSensor(args, req.username, req.orgname);
        console.log(`message result is : ${message}`)

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);

    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getSensorId/:sensorId', async function (req, res) {
    try {
        const id = req.params.sensorId;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.querySensorId(id, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getSensorsType/:sensorType', async function (req, res) {
    try {
        const sensorType = req.params.sensorType;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.querySensorsType(sensorType, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getSensorsTypeAvailable/:sensorType', async function (req, res) {
    try {
        const sensorType = req.params.sensorType;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.querySensorsTypeAvailable(sensorType, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getAllSensors', async function (req, res) {
    try {
        const sensorType = req.params.sensorType;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.queryAllSensors(req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.delete('/deleteSensorId/:sensorId', async function (req, res) {
    try {
        const id = req.params.sensorId; // Récupérer l'ID du capteur à partir des paramètres de requête

        logger.debug('==================== DELETE SENSOR ==================');
        
        let message = await del.deleteSensorId(id, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.put('/updateSensorPatientName', async function (req, res) {
    try {
        var {sensorId, newPatientName } = req.body;
        if (!sensorId || !newPatientName) {
            res.status(400).json({ error: 'Paramètres manquants' });
            return;
        }
        var args = [sensorId, newPatientName];
        logger.debug('args  : ' + args);
        logger.debug('==================== UPDATE SENSOR PATIENT NAME ==================');

        let message = await update.updateSensor(args, req.username, req.orgname);
        console.log(`message result is : ${message}`)

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);

    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

// Using the capsules
app.post('/createCapsuleMannually', async function (req, res) {
    try {
        logger.debug('==================== INVOKE ON CHAINCODE ==================');
        var {id, sensorId, valueA, valueB } = req.body;
        console.log(id, sensorId, valueA, valueB);
        if (!id || !sensorId || !valueA || !valueB) {
            res.status(400).json({ error: 'Paramètres manquants' });
            return;
        }

        console.log(req.username, req.orgname);
        var sensor = await query.querySensorId(sensorId, req.username, req.orgname);
        var args = [id, sensor.SensorId, sensor.SensorType, Date.now(), sensor.Patient, valueA, valueB];
        logger.debug('args  : ' + args);

        let message = await invoke.createCapsule(args, req.username, req.orgname);
        console.log(`message result is : ${message}`)

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);

    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getCapsuleId/:id', async function (req, res) {
    try {
        const id = req.params.id;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.queryCapsuleId(id, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getCapsulePrivateDataId/:id', async function (req, res) {
    try {
        const id = req.params.id;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.queryCapsulePrivateDataId(id, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getCapsuleByPatient/:patient', async function (req, res) {
    try {
        const patient = req.params.patient;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.queryCapsuleByPatient(patient, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});

app.get('/getPrivateCapsuleByPatient/:patient', async function (req, res) {
    try {
        const patient = req.params.patient;
        logger.debug('==================== QUERY BY CHAINCODE ==================');

        let message = await query.queryPrivateCapsuleByPatient(patient, req.username, req.orgname);

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }

        res.send(response_payload);
    } catch (error) {
        const response_payload = {
            result: null,
            error: error.name,
            errorData: error.message
        }
        res.send(response_payload)
    }
});