#!/bin/bash

# build and run the web server
function startRestServer() {
    # Needs the builded image to run.
    infoln "Starting Rest API Server"

    #mkdir ./rest-api-go/go/crypto-config
    cp -r crypto-config ./rest-api-go/go/

    docker build --tag rest-api-go ./rest-api-go/go/.
    #docker run -d --net hyperledger-custom-network_fabric-network -p 3000:3000 --name rest-api-go rest-api-go 
    docker run -d --net biochain-ai_fabric-network -p 3000:3000 --name rest-api-go rest-api-go 

}

# Kills and run a new web server
function restartRestServer (){
    docker stop rest-api-go
    docker rm rest-api-go

    rm -r ./rest-api-go/go/crypto-config
    
    sleep 1s

    #mkdir ./rest-api-go/go/crypto-config
    cp -r crypto-config ./rest-api-go/go/

    docker build --tag rest-api-go ./rest-api-go/go/.
    #docker run -d --net hyperledger-custom-network_fabric-network -p 3000:3000 --name rest-api-go rest-api-go
    docker run -d --net biochain-ai_fabric-network -p 3000:3000 --name rest-api-go rest-api-go
}