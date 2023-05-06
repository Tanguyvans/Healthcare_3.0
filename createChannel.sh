export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/network.com/orderers/orderer.network.com/msp/tlscacerts/tlsca.network.com-cert.pem
export PEER0_HOSPITAL_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/ca.crt
export PEER0_CARDIOLOGY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/ca.crt
export PEER0_GENERALSERVICES_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer0Cardiology(){
    export CORE_PEER_LOCALMSPID="CardiologyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CARDIOLOGY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/cardiology.network.com/users/Admin@cardiology.network.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer1Cardiology(){
    export CORE_PEER_LOCALMSPID="CardiologyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CARDIOLOGY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/cardiology.network.com/users/Admin@cardiology.network.com/msp
    export CORE_PEER_ADDRESS=localhost:10051  
}

setGlobalsForPeer0GeneralServices(){
    export CORE_PEER_LOCALMSPID="GeneralServicesMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GENERALSERVICES_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/generalservices.network.com/users/Admin@generalservices.network.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
}

setGlobalsForPeer1GeneralServices(){
    export CORE_PEER_LOCALMSPID="GeneralServicesMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GENERALSERVICES_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/generalservices.network.com/users/Admin@generalservices.network.com/msp
    export CORE_PEER_ADDRESS=localhost:12051  
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-org1/*
    rm -rf ./api-2.0/org1-wallet/*
    rm -rf ./api-2.0/org2-wallet/*
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Hospital
    
    echo $CORE_PEER_TLS_ENABLED
    bin/peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.network.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

joinChannel(){
    setGlobalsForPeer0Hospital
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Hospital
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Cardiology
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Cardiology
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0GeneralServices
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1GeneralServices
    bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block   
}

updateAnchorPeers(){
    setGlobalsForPeer0Hospital
    bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.network.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Cardiology
    bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.network.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0GeneralServices
    bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.network.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto
createChannel
joinChannel
updateAnchorPeers