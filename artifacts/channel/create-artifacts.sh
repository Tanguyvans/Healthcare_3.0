
# chmod -R 0755 ./crypto-config
# # Delete existing artifacts
# rm -rf ./crypto-config
rm genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# ../../bin/cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo $CHANNEL_NAME

# Generate System Genesis block
../../bin/configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block

# Generate channel configuration block
../../bin/configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for HospitalMSP  ##########"
../../bin/configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./HospitalMSPanchors.tx -channelID $CHANNEL_NAME -asOrg HospitalMSP

echo "#######    Generating anchor peer update for CardiologyMSP  ##########"
../../bin/configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./CardiologyMSPanchors.tx -channelID $CHANNEL_NAME -asOrg CardiologyMSP

echo "#######    Generating anchor peer update for GeneralServicesMSP  ##########"
../../bin/configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./GeneralServicesMSPanchors.tx -channelID $CHANNEL_NAME -asOrg GeneralServicesMSP
