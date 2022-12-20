# Biochain-AI
Simple implementation of a blockchain network using Hyperledger Fabric

### Requirements
what do you need:
 - Docker
 - Go
 - [Minifabric](https://github.com/hyperledger-labs/minifabric) 

### Start the network

 - Create a temporary folder (it will contain all the files that wil be created during the execution)

	mkdir temp

 - Copy the `spec.yaml` file inside the folder (this is needed only if you want a network configuration different from the standerd one)
	
	cp spec.yaml ./temp

 - Move inside the created folder

	cd temp

 - To start the network with the custom configuration

	minifab up -o parma.com
   
   - the flag `-o parma.com` depends on the configuration used. If different organizations are used, the command will be different. It is not necessary in case the standerd configuration is used.


