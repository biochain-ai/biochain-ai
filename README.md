# Biochain-AI
This project allows to implement an Hyperledger blockchain that exploit private collection to share biological data between different organisations. This technology allows organisations to public bioilogical data into the ledger keeping it secret until one of the other organisations asks for it. The blockchain technology assures that all the transactions created are stored immutabily, granting accountability to every one of them. 

## Requirements
What you need:
 - Docker
 - Go
 - [Minifabric](https://github.com/hyperledger-labs/minifabric) 

## Start and stop the network 

 - Create a temporary folder (it will contain all the files that wil be created during the execution)

	`mkdir temp`

 - Copy the `spec.yaml` file inside the folder (this is needed only if you want a network configuration different from the standerd one)
	
	`cp spec.yaml ./temp`

 - Move inside the created folder

	`cd temp`

 - To start the network with the custom configuration

	`minifab up -o parma.com`
   
   - the flag `-o parma.com` depends on the configuration used. If different organizations are used, the command will be different. It is not necessary in case the standerd configuration is used.

 - After the last command completes, there will be a new folder called `vars` in which all the files belonging to the created blockchain will be stored. We will
   explore this folder in the following commands.

 - To stop the network

	`minifab down`

 - To remove all the files created and delete the network forever

	`minifab cleanup`

## Install a chaincode (go lang)

 - The code must be stored in a folder called `go` inside a folder named like the chaincode. E.g. `chaincodeName/go/`
 - This folder must be placed inside `vars/chaincode/`

	`cp -R chaincodeName/  temp/vars/chaincode/`

 - To install the chaincode

	`minifab ccup -n chaincodeName -l go -v 1.0`
	
    - The `-n` flag specify the name, `-l` the language of the chaincode and `-v` the version
	- If you need to to upgrade the chaincode, after changing the code, you can simply repeat the previuos command incrementing the version number

## Install chaincode that uses private data and transient data
  In order to install a chaincode that uses private data and transient data, some extra steps are needed

 - After creating the network, the code must be stored in the same folder structure as seen before.

 - To install the chaincode run

	`minifab install -n chaincodeName -r true`

 	- A file called `chaincodeName_collection_config.json` will be creted. This files describe the features of the private collection that will be created. This file must be modified in order to obtain the desired configuration. In our case, we will replace this file with the file `biosharing_collection_config.json`

 - To commit the chaincode execute the following command

	`minifab approve,commit,initialize -p '' `

### Install biosharing chaincode
 - Copy all the contents of the folder `biosharing` in `vars/chaincode`
 - Execute `minifab install -n biosharing -r true`
 - Copy `biosharing_collection_config.json` in the folder `vars/`
 - Execute `minifab approve,commit,initialize -p '' `
## Interact with the blockchain
To change the organization that performs the transaction, the name after the `-o` flag must be changed. In `spec.yaml` file are listed all the organizations

This calls depends on the methods in the blockchain
#### View all the public data

`minifab invoke -p '"viewCatalogue"' -o parma.com`

#### View all the personal private data

`minifab invoke -p '"getPrivateData"' -o parma.com`

#### View the personal public data

`minifab invoke -p '"viewPersonalData"' -o parma.com`

#### Insert data

`DATA=$( echo '{"name":"PrimoDato","description":"descrizione del primo dato",data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )`
	
`minifab invoke -p '"insertData"' -t '{"data":"'$DATA'"}' -o parma.com`

#### Request data
The second argument must be the name of the data

`minifab invoke -p '"requestData","PrimoDato"' -o parma.com`

#### View Personal sharing requests

`minifab invoke -p '"viewRequests"' -o parma.com`

#### Accept sharing request
The second argument is the number of the request. This number can be seen in the request

`minifab invoke -p '"acceptRequest","1"'  -o parma.com`

#### Deny sharing request

`minifab invoke -p '"denyRequest","1"'  -o parma.com`