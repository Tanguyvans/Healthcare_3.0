const express = require('express');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');

const app = express();
const port = 3000;

const channelName = 'mychannel';
const chaincodeName = 'mychaincode';
const userName = 'user1';
const walletPath = path.join(process.cwd(), 'wallet');

// Connect to the Fabric network
async function connectToNetwork() {
  const gateway = new Gateway();
  await gateway.connect(path.join(process.cwd(), 'connection.json'), {
    wallet: await Wallets.newFileSystemWallet(walletPath),
    identity: userName,
    discovery: { enabled: true, asLocalhost: true },
  });
  const network = await gateway.getNetwork(channelName);
  const contract = network.getContract(chaincodeName);
  return { gateway, contract };
}

// Disconnect from the Fabric network
async function disconnectFromNetwork(gateway) {
  await gateway.disconnect();
}

// Define a route to query chaincode
app.get('/query', async (req, res) => {
  try {
    const { gateway, contract } = await connectToNetwork();

    // Invoke a query on the chaincode
    const result = await contract.evaluateTransaction('Query', 'key1');

    // Convert the result buffer to a string
    const data = result.toString();

    await disconnectFromNetwork(gateway);

    res.send(data);
  } catch (error) {
    console.error(`Error querying chaincode: ${error}`);
    res.status(500).send('An error occurred');
  }
});

// Define a route to submit chaincode transaction
app.post('/transaction', async (req, res) => {
  try {
    const { gateway, contract } = await connectToNetwork();

    // Perform the transaction using data from req.body
    const data = req.body;
    await contract.submitTransaction('Invoke', 'key1', data);

    await disconnectFromNetwork(gateway);

    res.send('Transaction submitted successfully');
  } catch (error) {
    console.error(`Error submitting transaction: ${error}`);
    res.status(500).send('An error occurred');
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
