# Export Hyperledger Fabric tools
export PATH=$PATH:${PWD}/bin
# Add path to the folder with bin files
export PATH=$PATH:~/go/src/github.com/jokerale/fabric-samples/bin
. scripts/fabric-ca.sh
. scripts/utils.sh
. scripts/web-server.sh  # script to start the web server
. scripts/rest-api-server.sh # script to start the rest api server

function removePreviousExecution() {
    infoln "Removing previous execution"
    # Remove web server
    docker stop web-server-php
    docker rm web-server-php

    # Remove rest api server
    docker stop rest-api-go
    docker rm rest-api-go

    # Remove previous execution
    docker-compose -f docker-compose-cli.yaml down --volumes --remove-orphans 2>/dev/null
    docker-compose -f docker-compose-ca.yaml down --volumes --remove-orphans 2>/dev/null
    docker-compose -f docker-compose-tls-ca.yaml down --volumes --remove-orphans 2>/dev/null

    # Remove fabric ca artifacts
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/brescia.com/ca/*' 2>/dev/null
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/brescia.com/tls.ca/*' 2>/dev/null
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/parma.com/ca/*' 2>/dev/null
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/parma.com/tls.ca/*' 2>/dev/null
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/orderer.example.com/ca/*' 2>/dev/null
    docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf fabric-ca/orderer.example.com/tls.ca/*' 2>/dev/null
    rm -rf ./channel-artifacts/ 2>/dev/null
    rm -rf ./crypto-config/ 2>/dev/null
    sleep 2s
}

function generateCryptoMaterials() {
    # Generate crypto materials
    infoln "Generating crypto materials"
    if [ ${CRYPTO_CONFIG} == "CA" ]; then
        # Generate artifacts using Fabric-ca
        generateTLSCryptoMaterials
        generateCaCryptoMaterials
        sleep 5s

    elif [ ${CRYPTO_CONFIG} == "Cryptogen" ]; then
        # Generate artifacts
        cryptogen generate --config=./crypto-config.yaml
    fi

    mkdir -p channel-artifacts
    configtxgen -profile TwoOrgsOrdererGenesis --channelID channel1 -outputBlock ./channel-artifacts/genesis_block.pb
    configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx --channelID channel1
    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/BresciaMSPanchors.tx --channelID channel1 -asOrg BresciaMSP
    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/ParmaMSPanchors.tx --channelID channel1 -asOrg ParmaMSP
    sleep 1s
}

function upDockerNetwork() {
    # Up network
    infoln "Network up"
    CHANNEL_NAME=channel1 docker-compose -f docker-compose-cli.yaml up -d
    sleep 1s
}

function createChannelAndJoin() {
    # Create channel1 and join orderer
    infoln "Creating channel1 and joining orderer"
    export OSN_TLS_CA_ROOT_CERT=${PWD}/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
    export ADMIN_TLS_SIGN_CERT=${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/client.crt
    export ADMIN_TLS_PRIVATE_KEY=${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/client.key
    osnadmin channel join --channelID channel1 --config-block ./channel-artifacts/genesis_block.pb -o localhost:7049 --ca-file $OSN_TLS_CA_ROOT_CERT --client-cert $ADMIN_TLS_SIGN_CERT --client-key $ADMIN_TLS_PRIVATE_KEY
    #docker exec -it cli bash -c "CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSP_CONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp peer channel create -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel.tx -c channel1 -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

    # export CORE_PEER_TLS_ENABLED=true
    # export CORE_PEER_LOCALMSPID="OrdererMSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/*.pem
    # export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
    # export CORE_PEER_ADDRESS=localhost:7050

    # infoln "Channel creation"
    # docker exec -it cli bash -c "peer channel create -o orderer.example.com:7050 -c channel1 -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

    # Join peers
    infoln "Joining peers"
    docker exec -it cli bash -c 'peer channel join -b ./channel-artifacts/genesis_block.pb'
    # docker exec -it cli bash -c 'peer channel update -o orderer.example.com:7050 -c channel1 -f ./channel-artifacts/ParmaMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'
    
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer channel join -b ./channel-artifacts/genesis_block.pb'
    # docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer channel update -o orderer.example.com:7050 -c channel1 -f ./channel-artifacts/BresciaMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'

    # # setting Anchor peers
    # infoln "Setting anchor peers"
    # infoln "  Brescia ORG"
    # #export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    # export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
    
    # export CORE_PEER_LOCALMSPID="BresciaMSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt
    # export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp
    # export CORE_PEER_ADDRESS=localhost:7051
    # #docker exec -it cli bash -c "peer channel fetch config ./channel-artifacts/genesis_block.pb -o 0.0.0.0:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile $ORDERER_CA" ##--certfile $CORE_PEER_TLS_ROOTCERT_FILE
    # docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer channel fetch config ./channel-artifacts/genesis_block.pb -c channel1"
    # #docker exec -it cli bash -c "cd channel-artifacts"
    # docker exec -it cli bash -c "configtxlator proto_decode --input ./channel-artifacts/genesis_block.pb --type common.Block --output ./channel-artifacts/config_block.json"
    # docker exec -it cli bash -c "jq .data.data[0].payload.data.config ./channel-artifacts/config_block.json > ./channel-artifacts/config.json"

    # docker exec -it cli bash -c "cp ./channel-artifacts/config.json ./channel-artifacts/config_copy.json"
    
    # docker exec -it cli bash -c "jq '.channel_group.groups.Application.groups.BresciaMSP.values += {\"AnchorPeers\":{\"mod_policy\": \"Admins\",\"value\":{\"anchor_peers\": [{\"host\": \"peer0.brescia.com\",\"port\": 7051}]},\"version\": \"0\"}}' ./channel-artifacts/config_copy.json > ./channel-artifacts/modified_config.json"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb"
    # docker exec -it cli bash -c "configtxlator compute_update --channel_id channel1 --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/config_update.pb"

    # infoln "    Configtxlator 5"
    # docker exec -it cli bash -c "configtxlator proto_decode --input ./channel-artifacts/config_update.pb --type common.ConfigUpdate --output ./channel-artifacts/config_update.json"
    # docker exec -it cli bash -c "echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"channel1\", \"type\":2}},\"data\":{\"config_update\": $(cat ./channel-artifacts/config_update.json) }}}' | jq . > ./channel-artifacts/config_update_in_envelope.json"
    # infoln "    Configtxlator 6"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/config_update_in_envelope.json --type common.Envelope --output ./channel-artifacts/config_update_in_envelope.pb"

    # #docker exec -it cli bash -c "peer channel update -f ./channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7049  --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem""
    # docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer channel update -f ./channel-artifacts/config_update_in_envelope.pb -o 0.0.0.0:7049 -c channel1"


    # infoln "  Parma ORG"
    # #export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    # export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
    
    # export CORE_PEER_LOCALMSPID="ParmaMSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt
    # export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp
    # export CORE_PEER_ADDRESS=localhost:7051
    # #docker exec -it cli bash -c "peer channel fetch config ./channel-artifacts/genesis_block.pb -o 0.0.0.0:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile $ORDERER_CA" ##--certfile $CORE_PEER_TLS_ROOTCERT_FILE
    # docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer channel fetch config ./channel-artifacts/genesis_block.pb -c channel1"
    # #docker exec -it cli bash -c "cd channel-artifacts"
    # docker exec -it cli bash -c "configtxlator proto_decode --input ./channel-artifacts/genesis_block.pb --type common.Block --output ./channel-artifacts/config_block.json"
    # docker exec -it cli bash -c "jq .data.data[0].payload.data.config ./channel-artifacts/config_block.json > ./channel-artifacts/config.json"

    # docker exec -it cli bash -c "cp ./channel-artifacts/config.json ./channel-artifacts/config_copy.json"
    
    # docker exec -it cli bash -c "jq '.channel_group.groups.Application.groups.ParmaMSP.values += {\"AnchorPeers\":{\"mod_policy\": \"Admins\",\"value\":{\"anchor_peers\": [{\"host\": \"peer0.parma.com\",\"port\": 7051}]},\"version\": \"0\"}}' ./channel-artifacts/config_copy.json > ./channel-artifacts/modified_config.json"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb"
    # docker exec -it cli bash -c "configtxlator compute_update --channel_id channel1 --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/config_update.pb"

    # infoln "    Configtxlator 5"
    # docker exec -it cli bash -c "configtxlator proto_decode --input ./channel-artifacts/config_update.pb --type common.ConfigUpdate --output ./channel-artifacts/config_update.json"
    # docker exec -it cli bash -c "echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"channel1\", \"type\":2}},\"data\":{\"config_update\": $(cat ./channel-artifacts/config_update.json) }}}' | jq . > ./channel-artifacts/config_update_in_envelope.json"
    # infoln "    Configtxlator 6"
    # docker exec -it cli bash -c "configtxlator proto_encode --input ./channel-artifacts/config_update_in_envelope.json --type common.Envelope --output ./channel-artifacts/config_update_in_envelope.pb"

    # #docker exec -it cli bash -c "peer channel update -f ./channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7049  --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem""
    # docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer channel update -f ./channel-artifacts/config_update_in_envelope.pb -o 0.0.0.0:7049 -c channel1"


    infoln "Get channel info"
    docker exec -it cli bash -c "peer channel getinfo -c channel1"


    infoln "Check channel join peers"
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer channel list'  
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer channel list'
}

function deployChaincode() {
    # Deploy chaincode BIOCHAIN
    infoln "Deploying chaincode BIOCHAIN"
    docker exec -it cli bash -c 'peer lifecycle chaincode package biosharing.tar.gz --path /opt/gopath/src/github.com/chaincode/biosharing/ --lang golang --label biosharing_1.0'
    infoln "Install"
    docker exec -it cli bash -c 'peer lifecycle chaincode install biosharing.tar.gz'
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer lifecycle chaincode install biosharing.tar.gz'

        infoln "QueryInstalled Parma"
        docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem  peer lifecycle chaincode queryinstalled --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt'
        infoln "QueryInstalled Brescia"
        docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem  peer lifecycle chaincode queryinstalled --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt'

    infoln "Install done"
    #docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode install biosharing.tar.gz'
    infoln "Lifecycle done"

    #docker exec -it cli bash -c 'peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --package-id biosharing_1.0:9cd1e8c5f0e29fe5d4a45fddbfa539157d81629598d7f8c6a7d45a98c514e454 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'
    infoln "Chaincode Approval"
    #docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id biosharing_1.0:69ebeda11aa1a2092337d81d5b4c1e2b50fdab79d9c9eb528a764fa4be94e907 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
    #docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id biosharing_1.0:69ebeda11aa1a2092337d81d5b4c1e2b50fdab79d9c9eb528a764fa4be94e907 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
    docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --init-required --waitForEvent --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id biosharing_1.0:6da6044cc69f12811fedb36402e51a695382fe6264209a97a9a51d0d47d113ea --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
    docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --init-required --waitForEvent --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id biosharing_1.0:6da6044cc69f12811fedb36402e51a695382fe6264209a97a9a51d0d47d113ea --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"


    infoln "Check commit readines"
    docker exec -it cli bash -c "peer lifecycle chaincode checkcommitreadiness --channelID channel1 --name biosharing --version 1.0 --sequence 1 --init-required --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --output json"

    infoln "Commit chaincode"
    docker exec -it cli bash -c "peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID channel1 --name biosharing --version 1.0 --sequence 1 --init-required --collections-config /opt/gopath/src/github.com/chaincode/biosharing/biosharing_collection_config.json --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem"

    infoln "Querycommitted"
    docker exec -it cli bash -c 'peer lifecycle chaincode querycommitted --channelID channel1 --name biosharing'
              #--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode querycommitted --channelID channel1 --name biosharing --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'

    infoln "Initializing chaincode 'biosharing'"
    if [ ${CRYPTO_CONFIG} == "CA" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/*.pem --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n biosharing --isInit -c '{\"Args\":[]}' "


    elif [ ${CRYPTO_CONFIG} == "Cryptogen" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n biosharing --isInit -c '{\"Args\":[]}' "
    fi

    # Deploy chaincode USER
    infoln "Deploying chaincode USER"
    docker exec -it cli bash -c 'peer lifecycle chaincode package user.tar.gz --path /opt/gopath/src/github.com/chaincode/user/ --lang golang --label user_1.0'
    infoln "Install"
    docker exec -it cli bash -c 'peer lifecycle chaincode install user.tar.gz'
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer lifecycle chaincode install user.tar.gz'

        infoln "QueryInstalled Parma"
        docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem  peer lifecycle chaincode queryinstalled --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt'
        infoln "QueryInstalled Brescia"
        docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem  peer lifecycle chaincode queryinstalled --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt'

    infoln "Install done"
    infoln "Lifecycle done"

    infoln "Chaincode Approval"
    docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name user --version 1.0 --init-required --waitForEvent --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id user_1.0:c7ea431879b26f358dc2beaef167efa7c0c1cd2dee23bf0e3ac86415bbbfc6f4 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
    docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID channel1 --name user --version 1.0 --init-required --waitForEvent --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --package-id user_1.0:c7ea431879b26f358dc2beaef167efa7c0c1cd2dee23bf0e3ac86415bbbfc6f4 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"


    infoln "Check commit readines"
    docker exec -it cli bash -c "peer lifecycle chaincode checkcommitreadiness --channelID channel1 --name user --version 1.0 --sequence 1 --init-required --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --output json"

    infoln "Commit chaincode"
    docker exec -it cli bash -c "peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID channel1 --name user --version 1.0 --sequence 1 --init-required --signature-policy \"OR('ParmaMSP.member','BresciaMSP.member')\" --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem"

    infoln "Querycommitted"
    docker exec -it cli bash -c 'peer lifecycle chaincode querycommitted --channelID channel1 --name user'
    docker exec -it cli bash -c 'CORE_PEER_LOCALMSPID=ParmaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/users/Admin@parma.com/msp CORE_PEER_ADDRESS=peer0.parma.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem peer lifecycle chaincode querycommitted --channelID channel1 --name user --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem'

    infoln "Initializing chaincode 'user'"
    if [ ${CRYPTO_CONFIG} == "CA" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/*.pem --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n user --isInit -c '{\"Args\":[]}' "


    elif [ ${CRYPTO_CONFIG} == "Cryptogen" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n user --isInit -c '{\"Args\":[]}' "
    fi
    #####

    sleep 5s

    #docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem -C channel1 -n biosharing --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/tlsca/tlsca.parma.com-cert.pem -c '{\"Args\":[\"Set\",\"User1\", \"Voter1\"]}'"
    infoln "Query viewCatalogue()"
    docker exec -it cli bash -c "peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewCatalogue\"]}'"

    infoln "Insert Data"
    #export KEYVALUE=$(echo -n "{\"key\":\"name\",\"value\":\"charlie\"}" | base64 | tr -d \\n)
    export DATA=$(echo '{"name":"PrimoDato","description":"descrizione del primo dato","data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )
    #docker exec -it cli bash -c "echo $DATA"
    ## changed a path and a file name of the PEM certificate
    # Il metodo verrà invocato dall'identità che ha l'MSP salvato nella variabile "CORE_PEER_MSPCONFIGPATH", essa infatti permette di settare il percorso per l'MSP dell'utente che vogliamo utilizzare

    infoln "Initializing chaincode 'biosharing'"
    if [ ${CRYPTO_CONFIG} == "CA" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/*.pem --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n biosharing -c '{\"Args\":[\"insertData\"]}' --transient '{\"data\":\"$DATA\"}' "
    elif [ ${CRYPTO_CONFIG} == "Cryptogen" ]; then
        docker exec -it cli bash -c "peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n biosharing -c '{\"Args\":[\"insertData\"]}' --transient '{\"data\":\"$DATA\"}' "

    fi

    sleep 10s
    infoln "Query viewCatalogue()"
    docker exec -it cli bash -c "peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewCatalogue\"]}'"

    sleep 5s
    infoln "Query getPrivateData()"
    docker exec -it cli bash -c "peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"getPrivateData\"]}'"
    
    
    sleep 2s
    infoln "Query viewPersonalData() Brescia"
    docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/Admin@brescia.com/msp CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"getPrivateData\"]}'"

}

# Default values

# Crypto materials generation (Cryptogen or CA)
CRYPTO_CONFIG="Cryptogen";

# INIT
while [[ $# -gt 0 ]]; do
    option=$1
    case ${option} in
    -h )
        printHelp
        exit 0
        ;;
    -ca|--ca)
        CRYPTO_CONFIG="CA"
        shift # past argument
        ;;
    -down|--down)
        removePreviousExecution
        exit 0
        ;;
    --restartWebServer|-rws)
        infoln "Restarting web server..."
        restartWebServer
        exit 0
        ;;
    --restartRestServer|-rrs)
        infoln "Restarting Rest server..."
        restartRestServer
        exit 0
        ;;
    * )
        errorln "Unknown flag: ${option}"
        printHelp
        exit 1
        ;;
    esac
done

removePreviousExecution
generateCryptoMaterials
upDockerNetwork
createChannelAndJoin
deployChaincode
startWebServer
startRestServer