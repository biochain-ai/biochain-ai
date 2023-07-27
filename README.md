# Biochain-AI
This project aims to create a system that allows different organizations to securely share biological data with the help of the blockchain.

## Project structure
The project consists into three main components which are the Hyperledger Blockchain, the Rest server, and the Web server.

The Hyperledger blockchain has a series of server communicating with eachother that allows to run custom smart contract called Chaincodes, written using Golang.

The Rest server is an API server that is used as single point of communication for the blockchain. Every request must be made using this API server. It is written in Golang.

The Web server allows to have a graphical interface useful to communicate the blockchain by sending API requests to the Rest server. 
It takes care of session management. It is written in PHP.

### Architecture
The whole system is structure ad follow:
at least two organizations must be present to create the system. The blockchain network is composed by a series 
of servers, the orderer and the organization's server. Every organization must have one to join the consortium since 
it is the place where its secret data is store inside the blockchain. So at the end of the process, the network will 
have at least 3 servers(one server for every chaincode installed in the server is created but they do not count in 
this phase since thay are created by the system).

At this point the blockchain can commmunicate using its own message passing protocol. Ideally, every organization keeps its logical server in one phisical server that can easily control.

The Rest api server is created to be the only point of connection with the blockchain network. Since it must have 
access to the organization's secret keys. Every organization must create its own Rest APi server.
This server allows to use the chiancode methods available into the smart contracts using a Api structure.

The last piece of the achitecture is the Web server. This server has been created to give a graphical and easy 
interface to the whole system. This server manage authentication, using Google credentials, and sends api 
requests to the Rest Server. Even in this case, every organization must create its own Web server since it must
forward request to the correct api server that owns the credential of the organization. 

## Folder Content
The mail folder contains some docker compose file used for the configuration of the blockchain network.
It also contains two configuration files also used for the configuration of the blockchain network.

`init.sh` is the bash script that allows to set up all the system, blockchain network, Rest Api server and Web server.
### `/base`
This folder contains the docker base configuration for the peers of the blockchain networks.
It also contain the docker compose file to set up the necessary servers, running in their own 
docker container, to run che blockchain system.

### `/bin`
This folder contains some useful file for the blockchain configuration.

### `/chiancode`
This folder contains the chiancodes (a.k.a smart contracts) that will be used in the blockchain.
They are stored individually inside their own folder.
The first chaincode is ***biosharing*** which controls all the things releted to the biological data(insert, delete, requests, etc...).
The second chaincode is ***user*** which controls all the things releted to the users who want to use the network.
It gives the possibility to add and remove users and to manage organizations. Every user is assigned to one organization in 
order to be able to see and manage the organization's data.

### `/fabric-ca`
This folder will contain all the secret informations releted to the organizations created during the start up phase of the blockchain. They will contain the private and public keys generated during the creation of the organizations.

### `/rest-api-go`
This folder contains the source files for the Rest Api server. This server allows to communicate with the 
blockchain system with the use of Api calls instead of complex commans from the command line. 
During the operational phase of the system, this server should be the only access point to the blockchian network.
Ideally, since the server need private keys to perform chiancode calls, every organization should have its how Rest server.

It is written using Golang.

### `/web-server-php`
This folder contains the source files for the Web Server. It allows to have a grafical interface, using a browser,
with the blockchain system. To use the services that this server makes available, the user *must* log-in 
with some Google credential. This server redirect all its requests to the Rest Api server which responds with Json data.

### `/scripts`
This folder contains some bash scripts that helps the main script `init.sh`.

## Requirements
- Docker
- Hyperledger Fabric samples
- For the web server: Google client ID and SECRET for the OAuth2 client which is
the web server. They must be saved as Env variable into the host running the
server

## User guide (to start a local configuration)
Use this simple commands to start, stop, and communicate with the network
#### Start the network
`./init.sh`

#### Stop the network
`./init.sh -down`

#### Add a user
`/scripts/new-user.sh`

#### Restart the Rest server
`./init.sh -rrs`

#### Restart the Web server
`./init.sh -rws`
