export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/network.com/orderers/orderer.network.com/msp/tlscacerts/tlsca.network.com-cert.pem
export PEER0_HOSPITAL_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/ca.crt
export PEER0_CARDIOLOGY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/ca.crt
export PEER0_GENERALSERVICES_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/
export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json
export CHANNEL_NAME=mychannel

. scripts/utils.sh
. scripts/enVar.sh

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/network.com/orderers/orderer.network.com/msp/tlscacerts/tlsca.network.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/network.com/users/Admin@network.com/msp

}

setGlobalsForPeer0Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
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

packageChaincode() {
    set -x
    bin/peer lifecycle chaincode package ${CC_NAME}.tar.gz \
            --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
            --label ${CC_NAME}_${CC_VERSION} >&log.txt
    res=$?
    PACKAGE_ID=$(bin/peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode packaging has failed"
    successln "Chaincode is packaged"
}

installChaincode() {
    setGlobalsForPeer0Hospital
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    if test $? -ne 0; then
        bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
        res=$?
    fi
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.hospital has failed"
    successln "Chaincode is installed on peer0.hospital"
    echo "===================== Chaincode is installed on peer0.hospital ===================== "

    setGlobalsForPeer0Cardiology
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    if test $? -ne 0; then
        bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
        res=$?
    fi
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.cardiology has failed"
    successln "Chaincode is installed on peer0.cardiology"

    echo "===================== Chaincode is installed on peer0.cardiology ===================== "

    setGlobalsForPeer0GeneralServices
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    if test $? -ne 0; then
        bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
        res=$?
    fi
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.generalservice has failed"
    successln "Chaincode is installed on peer0.generalservices"

    echo "===================== Chaincode is installed on peer0.generalservice ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Hospital
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Query installed on peer0.hospital has failed"
    successln "Query installed successful on peer0.hospital on channel"
}

approveForMyHospital() {
    setGlobalsForPeer0Hospital
    set -x
    bin/peer lifecycle chaincode approveformyorg -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.network.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} \
            --package-id ${PACKAGE_ID} \
            --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.hospital on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.hospital on channel '$CHANNEL_NAME'"
}

approveForMyCardiology() {
    setGlobalsForPeer0Cardiology
    set -x
    bin/peer lifecycle chaincode approveformyorg -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.network.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} \
            --package-id ${PACKAGE_ID} \
            --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.cardiology on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.caridology on channel '$CHANNEL_NAME'"
}

approveForMyGeneralServices() {
    setGlobalsForPeer0GeneralServices
    set -x
    bin/peer lifecycle chaincode approveformyorg -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.network.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} \
            --package-id ${PACKAGE_ID} \
            --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.generalservices on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.generalservices on channel '$CHANNEL_NAME'"
}

checkCommitReadinessHospital() {
    setGlobalsForPeer0Hospital

    infoln "Checking the commit readiness of the chaincode definition on peer0.hospital on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY

    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.hospital, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode checkcommitreadiness --collections-config $PRIVATE_DATA_CONFIG --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=0
        for var in "$@"; do
        grep "$var" log.txt &>/dev/null || let rc=1
        done
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.hospital on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.hospital is INVALID!"
    fi
}

checkCommitReadinessCardiology() {
    setGlobalsForPeer0Cardiology

    infoln "Checking the commit readiness of the chaincode definition on peer0.cardiology on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY

    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.cardiology, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode checkcommitreadiness --collections-config $PRIVATE_DATA_CONFIG --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=0
        for var in "$@"; do
        grep "$var" log.txt &>/dev/null || let rc=1
        done
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.cardiology on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.cardiology is INVALID!"
    fi
}

checkCommitReadinessGeneralServices() {
    setGlobalsForPeer0GeneralServices

    infoln "Checking the commit readiness of the chaincode definition on peer0.generalservices on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY

    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.generalservices, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode checkcommitreadiness --collections-config $PRIVATE_DATA_CONFIG --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=0
        for var in "$@"; do
        grep "$var" log.txt &>/dev/null || let rc=1
        done
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.generalservices on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.generalservices is INVALID!"
    fi
}

commitChaincodeDefinition() {
    set -x
    bin/peer lifecycle chaincode commit -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.network.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} \
            --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
            --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA \
            --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
            --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition commit failed on peer0.hospital on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition committed on channel '$CHANNEL_NAME'"
}

queryCommittedHospital() {
    setGlobalsForPeer0Hospital

    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.hospital on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.hospital, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: '$CC_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
        test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        successln "Query chaincode definition successful on peer0.hospital on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.hospital is INVALID!"
    fi
}

queryCommittedCardiology() {
    setGlobalsForPeer0Cardiology

    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.cardiology on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.cardiology, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: '$CC_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
        test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        successln "Query chaincode definition successful on peer0.cardiology on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.cardiology is INVALID!"
    fi
}

queryCommittedGeneralServices() {
    setGlobalsForPeer0GeneralServices

    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.generalservices on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.generalservices, Retry after $DELAY seconds."
        set -x
        bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: '$CC_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
        test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        successln "Query chaincode definition successful on peer0.generalservices on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.generalservices is INVALID!"
    fi
}

chaincodeInvokeSensor() {
    setGlobalsForPeer0Hospital

    bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.network.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA\
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
        -c '{"function": "InitLedger","Args":[]}'

    bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.network.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA\
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
        -c '{"function": "CreateSensor","Args":["sensor2", "cardiac", "Tanguy"]}'

    # bin/peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.network.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA\
    #     --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
    #     -c '{"function": "UpdateSensorPatientName","Args":["sensor1", "Tonny"]}'

    # bin/peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.network.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA\
    #     --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
    #     -c '{"function": "QuerySensorById","Args":["sensor1"]}'

    result=$(bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.network.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
        -c '{"function": "QuerySensorsByType","Args":["heart"]}' | jq -r '.payload.data')

    echo $result

}

chaincodeInvokeCapsule() {
    setGlobalsForPeer0Cardiology
    echo "chaincode invoke capsule"

    bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.network.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
        -c '{"function": "CreateCapsule","Args":["asset1","sensor1", "heart","2023-05-18T10:00:00Z", "Tanguy","10","20"]}'

    result=$(bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.network.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CARDIOLOGY_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_GENERALSERVICES_CA \
        -c '{"function": "QueryCapsulesByPatient","Args":["Said"]}' | jq -r '.payload.data')

    echo $result

    # Query private asset
    result=$(bin/peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["QueryPrivateCapsulesByPatient","Tanguy"]}')
    echo $result


}

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="node"
CC_VERSION="1"
CC_SRC_PATH="./artifacts/chaincode"
CC_NAME="capsule"
CC_SEQUENCE=${6:-"1"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
INIT_REQUIRED=""
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}

packageChaincode
installChaincode
queryInstalled
approveForMyHospital
approveForMyCardiology
approveForMyGeneralServices
commitChaincodeDefinition
queryCommittedHospital
queryCommittedCardiology
queryCommittedGeneralServices
sleep 5
chaincodeInvokeSensor
chaincodeInvokeCapsule