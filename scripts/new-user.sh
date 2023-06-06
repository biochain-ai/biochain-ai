#!/bin/bash

export PATH=$PATH:${PWD}/bin
export PATH=${PWD}/../../bin:$PATH
. scripts/fabric-ca.sh
. scripts/utils.sh

export ORG1=brescia
export ORG1MSP=BresciaMSP
export ORG2=parma
export ORG2MSP=ParmaMSP

infoln "Creating new user"

export NEWUSER=customuser1
export NEWUSERPW=customuser1pw
export NEWUSERFOLDERNAME=Customuser1
export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/admin

#infoln "User register"
#fabric-ca-client register --id.name ${NEWUSER} --id.secret ${NEWUSERPW} -u https://localhost:7054 --caname tls.ca.${ORG1}.com --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
#infoln "User enroll"
#fabric-ca-client enroll -u https://${NEWUSER}:${NEWUSERPW}@localhost:7054  --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
#cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/%{NEWUSERFOLDERNAME}@${ORG1}.com/msp/config.yaml"
# User register
#fabric-ca-client register --caname tls.ca.${ORG1}.com --id.name ${NEWUSER} --id.secret ${NEWUSERPW} --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

# User enroll
#fabric-ca-client enroll -u https://${NEWUSER}:${NEWUSERPW}@localhost:7055 --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
#cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERPW}@${ORG1}.com/msp/config.yaml"
infoln "User register"
fabric-ca-client register --id.name ${NEWUSER} --id.secret ${NEWUSERPW} -u https://localhost:7054 --caname tls.ca.${ORG1}.com --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
infoln "User enroll"
fabric-ca-client enroll -u https://${NEWUSER}:${NEWUSERPW}@localhost:7054 --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

infoln "Files copy"
# Copy the tls CA cert, server cert, server keystore to well known file names in the user's tls directory that are referenced by user startup config
cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/ca.crt"
cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/client.crt"
cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/tls/client.key"
infoln "Copying done"
export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG1}.com
# User register
fabric-ca-client register --caname ca.${ORG1}.com --id.name ${NEWUSER} --id.secret ${NEWUSERPW} --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
# User enroll
fabric-ca-client enroll -u https://${NEWUSER}:${NEWUSERPW}@localhost:7055 --caname ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/${NEWUSERFOLDERNAME}@${ORG1}.com/msp/config.yaml"


sleep 3s
infoln "Query viewCatalogue() Customuser1.Brescia"
docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/${NEWUSERFOLDERNAME}@brescia.com/msp/ CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewCatalogue\"]}'"

infoln "Query viewPersonalData() Customuser1.Brescia"
docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/${NEWUSERFOLDERNAME}@brescia.com/msp/ CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewPersonalData\"]}'"

sleep 2s
infoln "InsertData() Customuser1.Brescia"
export DATA=$(echo '{"name":"DatoCustomUser1Brescia","description":"descrizione del dato","data":"123123123ooooo"}' | base64 | tr -d \\n )
docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/${NEWUSERFOLDERNAME}@brescia.com/msp/ peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/*.pem --peerAddresses peer0.parma.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/parma.com/peers/peer0.parma.com/tls/ca.crt --peerAddresses peer0.brescia.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/peers/peer0.brescia.com/tls/ca.crt -C channel1 -n biosharing -c '{\"Args\":[\"insertData\"]}' --transient '{\"data\":\"$DATA\"}' "

sleep 3s
infoln "Query viewPersonalData() Customuser1.Brescia"
docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/${NEWUSERFOLDERNAME}@brescia.com/msp/ CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewPersonalData\"]}'"

sleep 2s
infoln "Query viewCatalogue() Customuser1.Brescia"
docker exec -it cli bash -c "CORE_PEER_LOCALMSPID=BresciaMSP CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/users/${NEWUSERFOLDERNAME}@brescia.com/msp/ CORE_PEER_ADDRESS=peer0.brescia.com:7051 CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brescia.com/tlsca/tlsca.brescia.com-cert.pem peer chaincode query -C channel1 -n biosharing -c '{\"Args\":[\"viewCatalogue\"]}'"

