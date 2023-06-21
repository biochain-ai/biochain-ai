# Biochain-AI
This project aims to create a system that allows different organizations to securely share biological data with the help of the blockchain.

## Project structure
The project consists into three main components which are the Hyperledger Blockchain, the Rest server, and the Web server.

The Hyperledger blockchain has a series of server communicating with eachother that alloews to run custom smart contract called Chaincodes, written using Golang.

The Rest server is an API server that is used as single point of communication for the blockchain. Every request must be made using this API server. It is written in Golang.

The Web server allows to have a graphical interface useful to communicato the blockchain by sending API requests to the Rest server. It is written in Golang.

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
