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
const port = 3000;

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

var server = http.createServer(app).listen(port, function () { console.log(`Server started on ${port}`) });
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************', host, port);
server.timeout = 240000;

app.post('/sensorCreateCapsule', async function (req, res) {
    try {
        logger.debug('==================== INVOKE ON CHAINCODE ==================');
        var sensorData = req.body;

        var id = Date.now().toString();
        var sensorId = sensorData.sensorId;
        var valueA = sensorData.valueA;
        var valueB = sensorData.valueB;

        console.log(id, sensorId, valueA, valueB);
        if (!id || !sensorId || !valueA || !valueB) {
            res.status(400).json({ error: 'Paramètres manquants' });
            return;
        }

        var sensor = await query.querySensorId(sensorId, "t1", "Hospital");

        var args = [id, sensor.SensorId, sensor.SensorType, Date.now().toString(), sensor.Patient, valueA, valueB];
        logger.debug('args  : ' + args);

        let message = await invoke.createCapsule(args, "t1", "Hospital");
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