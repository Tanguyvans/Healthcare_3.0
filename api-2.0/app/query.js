const { Gateway, Wallets, } = require('fabric-network');
const fs = require('fs');
const path = require("path")
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const util = require('util')

const helper = require('./helper')

// sensors
const querySensorId = async (id, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QuerySensorById", id);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const querySensorsType = async (sensorType, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QuerySensorsByType", sensorType);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const querySensorsTypeAvailable = async (sensorType, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QuerySensorsAvailableByType", sensorType);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const queryAllSensorsAvailable = async (username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryAllSensorsAvailable");
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const queryAllSensors = async (username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryAllSensors");
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

// capsule
const queryCapsuleId = async (id, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        console.log(id);
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryCapsuleId", id);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const queryCapsulePrivateDataId = async (id, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        console.log(id);
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryPrivateCapsuleId", id);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const queryCapsuleByPatient = async (patient, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        console.log(patient);
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryCapsulesByPatient", patient);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

const queryPrivateCapsuleByPatient = async (patient, username, org_name) => {
    var chaincodeName = "capsule";
    var channelName = "mychannel";
    try {
        console.log(patient);
        const ccp = await helper.getCCP(org_name) //JSON.parse(ccpJSON);
        const walletPath = await helper.getWalletPath(org_name) //.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(username);
        if (!identity) {
            console.log(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            await helper.getRegisteredUser(username, org_name, true)
            identity = await wallet.get(username);
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true }
        });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);
        let result = await contract.evaluateTransaction("QueryPrivateCapsulesByPatient", patient);
            
        console.log(result)
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

        result = JSON.parse(result.toString());
        return result
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        return error.message

    }
}

exports.querySensorId = querySensorId
exports.querySensorsType = querySensorsType
exports.querySensorsTypeAvailable = querySensorsTypeAvailable
exports.queryAllSensors = queryAllSensors
exports.queryAllSensorsAvailable = queryAllSensorsAvailable

exports.queryCapsuleId = queryCapsuleId
exports.queryCapsulePrivateDataId = queryCapsulePrivateDataId
exports.queryCapsuleByPatient = queryCapsuleByPatient
exports.queryPrivateCapsuleByPatient = queryPrivateCapsuleByPatient