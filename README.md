# Biochain-AI
Simple implementation of a blockchain network using Hyperledger Fabric

### Requirements
What you need:
 - Docker
 - Go
 - [Minifabric](https://github.com/hyperledger-labs/minifabric) 

### Start and stop the network 

 - Create a temporary folder (it will contain all the files that wil be created during the execution)

	`mkdir temp`

 - Copy the `spec.yaml` file inside the folder (this is needed only if you want a network configuration different from the standerd one)
	
	`cp spec.yaml ./temp`

 - Move inside the created folder

	`cd temp`

 - To start the network with the custom configuration

	`minifab up -o parma.com`
   
   - the flag `-o parma.com` depends on the configuration used. If different organizations are used, the command will be different. It is not necessary in case the standerd configuration is used.


 - To stop the network

	`minifab down`

 - To remove all the files created and delete the network forever

	`minifab cleanup`

### Install a chaincode (go lang)

 - The code must be stored in a folder called `go` inside a folder named like the chaincode. E.g. `chaincodeName/go/`
 - This folder must be placed inside `vars/chaincode/`

	`cp -R chaincodeName/go/  temp/vars/chaincode/`

 - To install the chaincode

	`minifab ccup -n chaincodeName -l go -v 1.0`
	
    - The `-n` flag specify the name, `-l` the language of the chaincode and `-v` the version

### Install chaincode that uses private data
_TODO_
### Invoke a chaincode method
_TODO_
