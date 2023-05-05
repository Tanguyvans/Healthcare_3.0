export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/
export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json
export CHANNEL_NAME=mychannel

. scripts/utils.sh
. scripts/enVar.sh

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051

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
    setGlobalsForPeer0Org1
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    if test $? -ne 0; then
        bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
        res=$?
    fi
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.org1 has failed"
    successln "Chaincode is installed on peer0.org1"
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer0Org2
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    if test $? -ne 0; then
        bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
        res=$?
    fi
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.org2 has failed"
    successln "Chaincode is installed on peer0.org2"

    echo "===================== Chaincode is installed on peer0.org2 ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Org1
    set -x
    bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${PACKAGE_ID}$ >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Query installed on peer0.org1 has failed"
    successln "Query installed successful on peer0.org1 on channel"
}

approveForMyOrg1() {
    setGlobalsForPeer0Org1
    set -x
    bin/peer lifecycle chaincode approveformyorg -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.example.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} \
            --package-id ${PACKAGE_ID} \
            --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.org1 on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.org1 on channel '$CHANNEL_NAME'"

}

approveForMyOrg2() {
    setGlobalsForPeer0Org2
    set -x
    bin/peer lifecycle chaincode approveformyorg -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.example.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} \
            --package-id ${PACKAGE_ID} \
            --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.org2 on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.org2 on channel '$CHANNEL_NAME'"
}

checkCommitReadyness() {
    setGlobalsForPeer0Org1
    bin/peer lifecycle chaincode checkcommitreadiness \
        --collections-config $PRIVATE_DATA_CONFIG \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

checkCommitReadinessOrg1() {
    setGlobalsForPeer0Org1

    infoln "Checking the commit readiness of the chaincode definition on peer0.org1 on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY

    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after $DELAY seconds."
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
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.org1 on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.org1 is INVALID!"
    fi
}

checkCommitReadinessOrg2() {
    setGlobalsForPeer0Org2

    infoln "Checking the commit readiness of the chaincode definition on peer0.org2 on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY

    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.org2, Retry after $DELAY seconds."
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
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.org2 on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.org2 is INVALID!"
    fi
}

commitChaincodeDefinition() {
    set -x
    bin/peer lifecycle chaincode commit -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.example.com --tls \
            --collections-config $PRIVATE_DATA_CONFIG \
            --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} \
            --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
            --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
            --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition commit failed on peer0.hospital on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition committed on channel '$CHANNEL_NAME'"
}

queryCommittedOrg1() {
    setGlobalsForPeer0Org1

    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.org1 on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.org1, Retry after $DELAY seconds."
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
        successln "Query chaincode definition successful on peer0.org1 on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.org1 is INVALID!"
    fi
}

queryCommittedOrg2() {
    setGlobalsForPeer0Org2

    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.org2 on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.org2, Retry after $DELAY seconds."
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
        successln "Query chaincode definition successful on peer0.org2 on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.org2 is INVALID!"
    fi
}

chaincodeInvoke() {
    setGlobalsForPeer0Org1

    bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "InitLedger","Args":[]}'

    export CAPSULE=$(echo -n "{\"key\":\"pcaps\", \"make\":\"Tesla\",\"model\":\"Tesla A1\",\"color\":\"White\",\"owner\":\"pavan\",\"price\":\"10000\"}" | base64 | tr -d \\n)
    bin/peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "CreatePrivateAsset","Args":[]}' \
        --transient "{\"capsule\":\"$CAPSULE\"}"
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
approveForMyOrg1
checkCommitReadinessOrg1 "\"Org1MSP\": true" "\"Org2MSP\": false"
checkCommitReadinessOrg2 "\"Org1MSP\": true" "\"Org2MSP\": false"
approveForMyOrg2
checkCommitReadinessOrg1 "\"Org1MSP\": true" "\"Org2MSP\": true"
checkCommitReadinessOrg2 "\"Org1MSP\": true" "\"Org2MSP\": true"
commitChaincodeDefinition
queryCommittedOrg1
queryCommittedOrg2
sleep 5
chaincodeInvoke