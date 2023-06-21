## Web Server
This folder contains all the necessary files for the web server application.
This web server create a web interface to communicate to the rest-server-api. It is the interface that must be used to talk to the blockchain network.

### Login
It uses the Google login to authenticate the user and after that checks if the user is registered into the blockchain. If it is not registered it cannot perform any request to the system. An admin user must add it into the ledger. 
If it is registered it can perform all the possible actions.