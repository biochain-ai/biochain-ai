#!/bin/bash

# build and run the web server
function startWebServer() {
    # Needs the builded image to run.
    infoln "Starting Web Server"
    docker build --tag web-server-go  ./web-server-go/.
    #docker run -d --net hyperledger-custom-network_fabric-network --env GOOGLE_OAUTH_CLIENT_ID --env GOOGLE_OAUTH_CLIENT_SECRET -p 8080:8080 --name web-server-go web-server-go
    docker run -d --net biochain-ai_fabric-network --env GOOGLE_OAUTH_CLIENT_ID --env GOOGLE_OAUTH_CLIENT_SECRET -p 8080:8080 --name web-server-go web-server-go
}

# Kills and run a new web server
function restartWebServer (){
    docker stop web-server-go
    docker rm web-server-go
    sleep 1s
    docker build --tag web-server-go  ./web-server-go/.
    #docker run -d --net hyperledger-custom-network_fabric-network --env GOOGLE_OAUTH_CLIENT_ID --env GOOGLE_OAUTH_CLIENT_SECRET -p 8080:8080 --name web-server-go web-server-go
    docker run -d --net biochain-ai_fabric-network --env GOOGLE_OAUTH_CLIENT_ID --env GOOGLE_OAUTH_CLIENT_SECRET -p 8080:8080 --name web-server-go web-server-go
}