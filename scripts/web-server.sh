#!/bin/bash

# build and run the web server
function startWebServer() {
    # Needs the builded image to run.
    infoln "Starting Web Server"
    docker build --tag web-server-php  ./web-server-php/.
    docker run -d --net biochain-ai_fabric-network --env GOOGLE_OAUTH_CLIENT_ID_TEST_CHAINCODE --env GOOGLE_OAUTH_CLIENT_SECRET_TEST_CHAINCODE -p 8080:80 --name web-server-php web-server-php
}

# Kills and run a new web server
function restartWebServer (){
    docker stop web-server-php
    docker rm web-server-php
    sleep 1s
    docker build --tag web-server-php  ./web-server-php/.
    docker run -d --net biochain-ai_fabric-network --env GOOGLE_OAUTH_CLIENT_ID_TEST_CHAINCODE --env GOOGLE_OAUTH_CLIENT_SECRET_TEST_CHAINCODE -p 8080:80 --name web-server-php web-server-php
}