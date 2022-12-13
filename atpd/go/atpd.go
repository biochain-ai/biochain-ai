package main

import (
	"log"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

// Define the existence of the asset
type Asset struct {
	Id    string
	Name  string
	Descr string
	Owner string
}

// Create a private Asset for the real data
type AssetData struct {
	Id   string
	Data string
}

type SmartContract struct {
}

func (c *SmartContract) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success([]byte("Init successful"))
}

func (c *SmartContract) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fc, _ := stub.GetFunctionAndParameters()
	if fc == "" {
		return shim.Error("No function name given")
	}
	return shim.Success([]byte("Well done!"))
}

func main() {
	// Start the chaincode process
	err := shim.Start(new(SmartContract))
	if err != nil {
		log.Print("Error starting PhantomChaincode - ", err.Error())
	}
}
