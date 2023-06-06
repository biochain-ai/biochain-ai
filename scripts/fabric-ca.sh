#!/bin/bash

. scripts/utils.sh

export ORG1=brescia
export ORG1MSP=BresciaMSP
export ORG2=parma
export ORG2MSP=ParmaMSP

function generateOrg1TLSCryptoMaterials() {
    infoln "Generating ORG 1 TLS crypto materials"
    mkdir -p crypto-config/peerOrganizations/${ORG1}.com/tls.ca/admin
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/admin
    fabric-ca-client enroll -u https://tlsadmin:tlsadminpw@localhost:7054 --caname tls.ca.${ORG1}.com -M msp --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    
    # Fabric CA register
    fabric-ca-client register --caname tls.ca.${ORG1}.com --id.name ca-server --id.secret ca-serverpw -u https://localhost:7054 --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    
    # Fabric CA enroll
    fabric-ca-client enroll -u https://ca-server:ca-serverpw@localhost:7054 --caname tls.ca.${ORG1}.com -M ../ca-server-admin/msp --csr.hosts 'localhost' --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Admin register
    fabric-ca-client register -u https://localhost:7054 --caname tls.ca.${ORG1}.com --id.name bresciaadmin --id.secret bresciaadminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    
    # Admin TLS
    fabric-ca-client enroll -u https://bresciaadmin:bresciaadminpw@localhost:7054 --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the admin's tls directory that are referenced by admin startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/client.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/tls/client.key"

    # Peer register
    fabric-ca-client register -u https://localhost:7054 --caname tls.ca.${ORG1}.com --id.name peer0 --id.secret peer0pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    
    # Peer TLS
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls --enrollment.profile tls --csr.hosts peer0.${ORG1}.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/server.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/tls/server.key"

    # User register
    fabric-ca-client register -u https://localhost:7054 --caname tls.ca.${ORG1}.com --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    
    # User TLS
    fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname tls.ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the user's tls directory that are referenced by user startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/client.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/tls/client.key"

    mkdir -p fabric-ca/${ORG1}.com/ca/tls
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/ca-server-admin/msp/signcerts/"* "${PWD}/fabric-ca/${ORG1}.com/ca/tls/cert.pem"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/ca-server-admin/msp/keystore/"* "${PWD}/fabric-ca/${ORG1}.com/ca/tls/key.pem"

    mv "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/admin/msp/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tls.ca/admin/msp/keystore/key.pem"

    # Copy parma's CA cert to parma's /tlsca directory (for use by clients)
    mkdir -p "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tlsca"
    cp "${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/tlsca/tlsca.${ORG1}.com-cert.pem"
}

function generateOrg2TLSCryptoMaterials() {
    infoln "Generating ORG 2 TLS crypto materials"
    mkdir -p crypto-config/peerOrganizations/${ORG2}.com/tls.ca/admin
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tls.ca/admin
    fabric-ca-client enroll -u https://tlsadmin:tlsadminpw@localhost:8054 --caname tls.ca.${ORG2}.com -M msp --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    
    # Fabric CA register
    fabric-ca-client register --caname tls.ca.${ORG2}.com --id.name ca-server --id.secret ca-serverpw -u https://localhost:8054 --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    
    # Fabric CA enroll
    fabric-ca-client enroll -u https://ca-server:ca-serverpw@localhost:8054 --caname tls.ca.${ORG2}.com -M ../ca-server-admin/msp --csr.hosts 'localhost' --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Admin register
    fabric-ca-client register -u https://localhost:8054 --caname tls.ca.${ORG2}.com --id.name parmaadmin --id.secret parmaadminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    
    # Admin TLS
    fabric-ca-client enroll -u https://parmaadmin:parmaadminpw@localhost:8054 --caname tls.ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the admin's tls directory that are referenced by admin startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/client.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/tls/client.key"

    # Peer register
    fabric-ca-client register -u https://localhost:8054 --caname tls.ca.${ORG2}.com --id.name peer0 --id.secret peer0pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    
    # Peer TLS
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname tls.ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls --enrollment.profile tls --csr.hosts peer0.${ORG2}.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/server.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/tls/server.key"

    # User register
    fabric-ca-client register -u https://localhost:8054 --caname tls.ca.${ORG2}.com --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    
    # User TLS
    fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname tls.ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the user's tls directory that are referenced by user startup config
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/tlscacerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/ca.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/signcerts/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/client.crt"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/tls/client.key"

    mkdir -p fabric-ca/${ORG2}.com/ca/tls
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tls.ca/ca-server-admin/msp/signcerts/"* "${PWD}/fabric-ca/${ORG2}.com/ca/tls/cert.pem"
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tls.ca/ca-server-admin/msp/keystore/"* "${PWD}/fabric-ca/${ORG2}.com/ca/tls/key.pem"

    mv "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tls.ca/admin/msp/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tls.ca/admin/msp/keystore/key.pem"

    # Copy parma's CA cert to parma's /tlsca directory (for use by clients)
    mkdir -p "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tlsca"
    cp "${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem" "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/tlsca/tlsca.${ORG2}.com-cert.pem"
}

function generateOrdererTLSCryptoMaterials() {
    infoln "Generating Orderer TLS crypto materials"
    mkdir -p crypto-config/ordererOrganizations/example.com/tls.ca/admin
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/example.com/tls.ca/admin
    fabric-ca-client enroll -u https://tlsadmin:tlsadminpw@localhost:9054 --caname tls.ca.orderer.example.com -M msp --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    
    # Fabric CA register
    fabric-ca-client register --caname tls.ca.orderer.example.com --id.name ca-server --id.secret ca-serverpw -u https://localhost:9054 --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    
    # Fabric CA enroll
    fabric-ca-client enroll -u https://ca-server:ca-serverpw@localhost:9054 --caname tls.ca.orderer.example.com -M ../ca-server-admin/msp --csr.hosts 'localhost' --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem

    # Admin register
    fabric-ca-client register -u https://localhost:9054 --caname tls.ca.orderer.example.com --id.name ordereradmin --id.secret ordereradminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    
    # Admin TLS
    fabric-ca-client enroll -u https://ordereradmin:ordereradminpw@localhost:9054 --caname tls.ca.orderer.example.com -M ${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls --enrollment.profile tls --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the admin's tls directory that are referenced by admin startup config
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/tlscacerts/"* "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/ca.crt"
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/signcerts/"* "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/client.crt"
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/keystore/"* "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/client.key"

    # Orderer register
    fabric-ca-client register -u https://localhost:9054 --caname tls.ca.orderer.example.com --id.name orderer1 --id.secret orderer1pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    
    # Orderer TLS
    fabric-ca-client enroll -u https://orderer1:orderer1pw@localhost:9054 --caname tls.ca.orderer.example.com -M ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem

    # Copy the tls CA cert, server cert, server keystore to well known file names in the orderers's tls directory that are referenced by orderers startup config
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

    mkdir -p fabric-ca/orderer.example.com/ca/tls
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/tls.ca/ca-server-admin/msp/signcerts/"* "${PWD}/fabric-ca/orderer.example.com/ca/tls/cert.pem"
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/tls.ca/ca-server-admin/msp/keystore/"* "${PWD}/fabric-ca/orderer.example.com/ca/tls/key.pem"

    mv "${PWD}/crypto-config/ordererOrganizations/example.com/tls.ca/admin/msp/keystore/"* "${PWD}/crypto-config/ordererOrganizations/example.com/tls.ca/admin/msp/keystore/key.pem"

    # Copy orderer's CA cert to orderer's /tlsca directory (for use by clients)
    mkdir -p "${PWD}/crypto-config/ordererOrganizations/example.com/tlsca"
    cp "${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem" "${PWD}/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
}

function generateOrg1CryptoMaterials() {
    # Generate artifacts using fabric-ca
    infoln "Generating ORG 1 crypto materials"
    mkdir -p crypto-config/peerOrganizations/${ORG1}.com
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG1}.com
    fabric-ca-client enroll -u https://admin:adminpw@localhost:7055 --caname ca.${ORG1}.com -M msp --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-7055-ca-brescia-com.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-7055-ca-brescia-com.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-7055-ca-brescia-com.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-7055-ca-brescia-com.pem
        OrganizationalUnitIdentifier: orderer' > "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml"

    # Peer register
    fabric-ca-client register --caname ca.${ORG1}.com --id.name peer0 --id.secret peer0pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Peer enroll
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7055 --caname ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/msp --csr.hosts peer0.${ORG1}.com --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/peers/peer0.${ORG1}.com/msp/config.yaml"

    
    # User register
    fabric-ca-client register --caname ca.${ORG1}.com --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # User enroll
    fabric-ca-client enroll -u https://user1:user1pw@localhost:7055 --caname ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/User1@${ORG1}.com/msp/config.yaml"

    # Admin register
    fabric-ca-client register --caname ca.${ORG1}.com --id.name bresciaadmin --id.secret bresciaadminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem

    # Admin enroll
    fabric-ca-client enroll -u https://bresciaadmin:bresciaadminpw@localhost:7055 --caname ca.${ORG1}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG1}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp/config.yaml"
    mv "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp/keystore/key.pem"
}

function generateOrg2CryptoMaterials() {
    # Generate artifacts using fabric-ca
    infoln "Generating ORG 2 crypto materials"
    mkdir -p crypto-config/peerOrganizations/${ORG2}.com
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${ORG2}.com
    fabric-ca-client enroll -u https://admin:adminpw@localhost:8055 --caname ca.${ORG2}.com --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-parma-com.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-parma-com.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-parma-com.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-parma-com.pem
        OrganizationalUnitIdentifier: orderer' > "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/msp/config.yaml"

    # Peer register
    fabric-ca-client register --caname ca.${ORG2}.com --id.name peer0 --id.secret peer0pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Peer enroll
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8055 --caname ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/msp --csr.hosts peer0.${ORG2}.com --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/peers/peer0.${ORG2}.com/msp/config.yaml"

    # User register
    fabric-ca-client register --caname ca.${ORG2}.com --id.name user1 --id.secret user1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # User enroll
    fabric-ca-client enroll -u https://user1:user1pw@localhost:8055 --caname ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/User1@${ORG2}.com/msp/config.yaml"


    # Admin register
    fabric-ca-client register --caname ca.${ORG2}.com --id.name parmaadmin --id.secret parmaadminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem

    # Admin enroll
    fabric-ca-client enroll -u https://parmaadmin:parmaadminpw@localhost:8055 --caname ca.${ORG2}.com -M ${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/msp --tls.certfiles ${PWD}/fabric-ca/${ORG2}.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/msp/config.yaml" "${PWD}/crypto-config/peerOrganizations/${ORG2}.com/users/Admin@${ORG2}.com/msp/config.yaml"
    mv "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp/keystore/"* "${PWD}/crypto-config/peerOrganizations/${ORG1}.com/users/Admin@${ORG1}.com/msp/keystore/key.pem"
}

function generateOrdererCryptoMaterials() {
    # Generate artifacts using fabric-ca
    mkdir -p crypto-config/ordererOrganizations/example.com/
    infoln "Generating Orderer crypto materials"
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/example.com/
    fabric-ca-client enroll -u https://admin:adminpw@localhost:9055 --caname ca.orderer.example.com --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-9055-ca-orderer-example-com.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-9055-ca-orderer-example-com.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-9055-ca-orderer-example-com.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-9055-ca-orderer-example-com.pem
        OrganizationalUnitIdentifier: orderer' > "${PWD}/crypto-config/ordererOrganizations/example.com/msp/config.yaml"

    # Orderer register
    fabric-ca-client register --caname ca.orderer.example.com --id.name orderer --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem

    # Orderer enroll
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9055 --caname ca.orderer.example.com -M ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

    # Admin register
    fabric-ca-client register --caname ca.orderer.example.com --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem

    # Admin enroll
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9055 --caname ca.orderer.example.com -M ${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem
    cp "${PWD}/crypto-config/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
    mv "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/keystore/"* "${PWD}/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/keystore/key.pem"

    # Copy orderer's CA cert to orderer's /msp/tlscacerts directory (for use in the channel MSP definition)
    mkdir -p "${PWD}/crypto-config/ordererOrganizations/example.com/msp/tlscacerts"
    cp "${PWD}/fabric-ca/orderer.example.com/tls.ca/ca-cert.pem" "${PWD}/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

    cp "${PWD}/crypto-config/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"
}

function generateTLSCryptoMaterials(){
    # Up fabric-tls-ca
    infoln "Fabric TLS-CA"
    docker-compose -f docker-compose-tls-ca.yaml up -d
    sleep 1s
    generateOrg1TLSCryptoMaterials
    generateOrg2TLSCryptoMaterials
    generateOrdererTLSCryptoMaterials
}

function generateCaCryptoMaterials(){
    # Up fabric-ca
    infoln "Fabric CA"
    docker-compose -f docker-compose-ca.yaml up -d
    sleep 1s
    generateOrg1CryptoMaterials
    generateOrg2CryptoMaterials
    generateOrdererCryptoMaterials
}