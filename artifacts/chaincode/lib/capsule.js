/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

// Deterministic JSON.stringify()
const stringify  = require('json-stringify-deterministic');
const sortKeysRecursive  = require('sort-keys-recursive');
const { Contract } = require('fabric-contract-api');
const { classToPlain } = require('class-transformer');

class Capsule extends Contract {

    async AssetExists(ctx, assetId) {
        const buffer = await ctx.stub.getState(assetId);
        return !!buffer && buffer.length > 0;
    }
    
    async InitLedger(ctx) {

        const sensors = [
            {
                SensorId: "s1",
                DataType: "sensorData",
                SensorType: 'heart',
                Patient: 'Said',
            },
            {
                SensorId: "s2",
                DataType: "sensorData",
                SensorType: 'Lungs',
                Patient: 'Mathis',
            }
        ];

        for (const sensor of sensors) {
            sensor.docType = 'asset';
            await ctx.stub.putState(sensor.SensorId, Buffer.from(stringify(sortKeysRecursive(sensor))));
        }
    }
    // sensor functions
    async CreateSensor(ctx, sensorId, sensorType, patient) {
        const exists = await this.AssetExists(ctx, sensorId);
        if (exists) {
            throw new Error(`The asset ${sensorId} already exists`);
        }

        const sensorData = {
            SensorId: sensorId,
            DataType: "sensorData",
            Patient: patient,
            SensorType: sensorType
          };
        
        await ctx.stub.putState(sensorId, Buffer.from(JSON.stringify(sensorData)));
        return JSON.stringify(sensorData);
    }

    async UpdateSensorPatientName(ctx, sensorId, newPatientName) {
        const sensorDataBytes = await ctx.stub.getState(sensorId);
        if (!sensorDataBytes || sensorDataBytes.length === 0) {
            throw new Error(`Sensor data with ID '${sensorId}' does not exist`);
        }
      
        const sensorData = JSON.parse(sensorDataBytes.toString());
        sensorData.Patient = newPatientName;
      
        await ctx.stub.putState(sensorId, Buffer.from(JSON.stringify(sensorData)));
        return JSON.stringify(sensorData);
    }

    async DeleteSensor(ctx, sensorId) {
        const exists = await this.AssetExists(ctx, sensorId);
        if (!exists) {
            throw new Error(`The asset ${sensorId} does not exist`);
        }
      
        await ctx.stub.deleteState(sensorId);
    }
    
    async QuerySensorById(ctx, sensorId) {
        const sensorDataBytes = await ctx.stub.getState(sensorId);
        if (!sensorDataBytes || sensorDataBytes.length === 0) {
            throw new Error(`Sensor data with ID '${sensorId}' does not exist`);
        }
      
        const sensorData = JSON.parse(sensorDataBytes.toString());
        return JSON.stringify(sensorData);
    }

    async QuerySensorsByType(ctx, sensorType) {
        const startKey = '';
        const endKey = '';
      
        const iterator = await ctx.stub.getStateByRange(startKey, endKey);
      
        const sensorsByType = [];
      
            while (true) {
                const sensorData = await iterator.next();
                if (sensorData.value && sensorData.value.value.toString()) {
                    const parsedSensorData = JSON.parse(sensorData.value.value.toString());
                    if (parsedSensorData.DataType === 'sensorData' && parsedSensorData.SensorType === sensorType) {
                        sensorsByType.push(parsedSensorData);
                    }
                }
            
                if (sensorData.done) {
                    await iterator.close();
                    break;
                }
            }
      
        return JSON.stringify(sensorsByType);
    }
    
    async QuerySensorsAvailableByType(ctx, sensorType) {
        const startKey = '';
        const endKey = '';
      
        const iterator = await ctx.stub.getStateByRange(startKey, endKey);
      
        const sensorsByType = [];
      
            while (true) {
                const sensorData = await iterator.next();
                if (sensorData.value && sensorData.value.value.toString()) {
                    const parsedSensorData = JSON.parse(sensorData.value.value.toString());
                    if (parsedSensorData.DataType === 'sensorData' && parsedSensorData.SensorType === sensorType && parsedSensorData.Patient === "none") {
                        sensorsByType.push(parsedSensorData);
                    }
                }
            
                if (sensorData.done) {
                    await iterator.close();
                    break;
                }
            }
      
        return JSON.stringify(sensorsByType);
    }

    async QueryAllSensors(ctx) {
        const startKey = '';
        const endKey = '';
      
        const iterator = await ctx.stub.getStateByRange(startKey, endKey);
      
        const sensorsByType = [];
      
            while (true) {
                const sensorData = await iterator.next();
                if (sensorData.value && sensorData.value.value.toString()) {
                    const parsedSensorData = JSON.parse(sensorData.value.value.toString());
                    if (parsedSensorData.DataType === 'sensorData') {
                        sensorsByType.push(parsedSensorData);
                    }
                }
            
                if (sensorData.done) {
                    await iterator.close();
                    break;
                }
            }
      
        return JSON.stringify(sensorsByType);
    }

    // capsule functions
    async CreateCapsule(ctx, id, sensorId, sensorType, timestamp, patient, valueA, valueB) {
        const collectionName = 'collectionCapsulePrivateDetails';

        const asset = {
            ID: id,
            SensorID: sensorId,
            DataType: "capsuleData",
            SensorType: sensorType,
            TimeStamp: timestamp,
            Patient: patient,
            valueA: ctx.stub.createCompositeKey('asset~valueA', [id]),
            valueB: ctx.stub.createCompositeKey('asset~valueB', [id]),
        };
    
        // Save the public data to the ledger
        await ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    
        // Save the private data to the collection
        await ctx.stub.putPrivateData(collectionName, asset.valueA, Buffer.from(valueA));
        await ctx.stub.putPrivateData(collectionName, asset.valueB, Buffer.from(valueB));
    
        return JSON.stringify(asset);
    }

    async QueryCapsuleId(ctx, id) {
        // Retrieve the asset from public data
        const assetJSON = await ctx.stub.getState(id);
    
        if (!assetJSON || assetJSON.length === 0) {
          throw new Error(`Asset ${id} does not exist`);
        }
    
        return assetJSON.toString();
    }

    async QueryPrivateCapsuleId(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);

        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`Asset ${id} does not exist`);
        }

        const collectionName = 'collectionCapsulePrivateDetails';
        // Retrieve the private data for valueA and valueB
        const valueAKey = ctx.stub.createCompositeKey('asset~valueA', [id]);
        const valueBKey = ctx.stub.createCompositeKey('asset~valueB', [id]);

        const valueA = await ctx.stub.getPrivateData(collectionName, valueAKey);
        const valueB = await ctx.stub.getPrivateData(collectionName, valueBKey);

        if (!valueA || valueA.length === 0 || !valueB || valueB.length === 0) {
            throw new Error(`Private data for asset ${id} does not exist`);
        }

        const privateData = {
            valueA: valueA.toString(),
            valueB: valueB.toString(),
        };

        const assetData = JSON.parse(assetJSON.toString());
        assetData.privateData = privateData;

        return JSON.stringify(assetData);
    }

    async QueryCapsulesByPatient(ctx, patient) {
        const startKey = '';
        const endKey = '';
      
        const iterator = await ctx.stub.getStateByRange(startKey, endKey);
        const capsulesByPatient = [];
      
        while (true) {
            const result = await iterator.next();
        
            if (result.value && result.value.value.toString()) {
            const capsuleData = JSON.parse(result.value.value.toString());
        
            if (capsuleData.DataType === 'capsuleData' && capsuleData.Patient === patient) {
                capsulesByPatient.push(capsuleData);
            }
            }
        
            if (result.done) {
            await iterator.close();
            break;
            }
        }
        
        return JSON.stringify(capsulesByPatient);
    }

    async QueryPrivateCapsulesByPatient(ctx, patient) {
        const collectionName = 'collectionCapsulePrivateDetails';
        const startKey = '';
        const endKey = '';
      
        const iterator = await ctx.stub.getStateByRange(startKey, endKey);
        const capsulesByPatient = [];
      
        while (true) {
            const result = await iterator.next();
        
            if (result.value && result.value.value.toString()) {
                const capsuleData = JSON.parse(result.value.value.toString());
        
                if (capsuleData.DataType === 'capsuleData' && capsuleData.Patient === patient) {
                const privateDataA = await ctx.stub.getPrivateData(collectionName, capsuleData.valueA);
                const privateDataB = await ctx.stub.getPrivateData(collectionName, capsuleData.valueB);
        
                const parsedCapsuleData = {
                    ...capsuleData,
                    privateValueA: privateDataA.toString('utf8'),
                    privateValueB: privateDataB.toString('utf8')
                };
        
                capsulesByPatient.push(parsedCapsuleData);
                }
            }
        
            if (result.done) {
                await iterator.close();
                break;
            }
        }
        return JSON.stringify(capsulesByPatient);
    }
      
      
    
}

module.exports = Capsule;
