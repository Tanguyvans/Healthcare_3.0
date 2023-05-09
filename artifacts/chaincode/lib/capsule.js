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

    async InitLedger(ctx) {

        const assets = [
            {
                ID: "capsule1",
                SensorID: 101,
                SensorType: 'heart',
                TimeStamp: '2021-04',
                Patient: 'Said',
                value: 300,
            },
            {
                ID: "capsule2",
                SensorID: 102,
                SensorType: 'Lungs',
                TimeStamp: '2021-05',
                Patient: 'Mathis',
                value: 200,
            },
            {
                ID: "capsule3",
                SensorID: 103,
                SensorType: 'Diabetes',
                TimeStamp: '2022-05',
                Patient: 'Mathis',
                value: 200,
            },
        ];

        for (const asset of assets) {
            asset.docType = 'asset';
            // example of how to write to world state deterministically
            // use convetion of alphabetic order
            // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
            // when retrieving data, in any lang, the order of data will be the same and consequently also the corresonding hash
            await ctx.stub.putState(asset.ID, Buffer.from(stringify(sortKeysRecursive(asset))));
        }
    }

    // CreateAsset issues a new asset to the world state with given details.
    async CreateAsset(ctx, id, sensorId, sensorType, timeStamp, patient, value) {
        const exists = await this.AssetExists(ctx, id);
        if (exists) {
            throw new Error(`The asset ${id} already exists`);
        }

        const asset = {
            ID: id,
            SensorID: sensorId,
            SensorType: sensorType,
            TimeStamp: timeStamp,
            Patient: patient,
            value: value,
        };
        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(id, Buffer.from(stringify(sortKeysRecursive(asset))));
        return JSON.stringify(asset);
    }

    async CreatePrivateAsset(ctx) {
        const collectionName = 'collectionCapsulePrivateDetails';
        const transientData = await ctx.stub.getTransient();

        if (transientData) {
            const capsuleData = transientData.get('capsule');
        
            // Vérifier si la donnée transitoire "capsule" existe et la traiter si c'est le cas
            if (capsuleData) {
                const capsule = JSON.parse(capsuleData.toString());
            
                // Ajouter la capsule à la collection de données privées
                await ctx.stub.putPrivateData(collectionName, capsule.key, Buffer.from(JSON.stringify(capsule)));
            
                // Retourner la capsule ajoutée en tant que résultat
                return capsule;
            }
         }
        
        // Si aucune donnée transitoire n'a été trouvée, renvoyer une erreur
        throw new Error('No transient data found');
    }

    async ReadAssetByID(ctx, id) {
        const assetBuffer = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetBuffer || assetBuffer.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }
        const assetJSON = assetBuffer.toString('utf8');
        return JSON.parse(assetJSON);
    }

    async ReadAssetByPatient(ctx, patientName) {
        const iterator = await ctx.stub.getStateByRange('', ''); // Get all assets
        const results = [];
        let res = await iterator.next();
      
        while (!res.done) {
          const strValue = Buffer.from(res.value.value.toString()).toString('utf8');
          const asset = JSON.parse(strValue);
      
          if (asset.Patient === patientName) { // Filter assets by patient name
            results.push(asset);
          }
      
          res = await iterator.next();
        }
      
        await iterator.close();
        return JSON.stringify(results);
    }

    // UpdateAsset updates an existing asset in the world state with provided parameters.
    async UpdateAsset(ctx, id, color, size, owner, appraisedValue) {
        const exists = await this.AssetExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }

        // overwriting original asset with new asset
        const updatedAsset = {
            ID: id,
            SensorID: sensorId,
            SensorType: sensorType,
            TimeStamp: timeStamp,
            Patient: patient,
            value: value,
        };
        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        return ctx.stub.putState(id, Buffer.from(stringify(sortKeysRecursive(updatedAsset))));
    }

    // DeleteAsset deletes an given asset from the world state.
    async DeleteAsset(ctx, id) {
        const exists = await this.AssetExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return ctx.stub.deleteState(id);
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    // TransferAsset updates the owner field of asset with given id in the world state.
    async TransferAsset(ctx, id, newOwner) {
        const assetString = await this.ReadAsset(ctx, id);
        const asset = JSON.parse(assetString);
        const oldOwner = asset.Owner;
        asset.Owner = newOwner;
        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(id, Buffer.from(stringify(sortKeysRecursive(asset))));
        return oldOwner;
    }

    // GetAllAssets returns all assets found in the world state.
    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push(record);
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }

}

module.exports = Capsule;
