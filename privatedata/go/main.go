/*
First test of smartcontract

This smartcontract will allow users to:
 - insert data into their private database
 - make requests to obtain data of other users
 - accept or deny requests from other users to share data
 - inform everyone of the data available for sharing

*/

package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

// Chanicode struct
type Chaincode struct {
}

// Asset used to track ownership of the data, publicly
type dataProperty struct {
	Id    string
	Owner string
}

// Asset used to describe the data
type dataDescription struct {
	Id          string
	Description string
}

// Asset used in the private databases to store the actual data
type dataBioPrivateDetails struct {
	Id   string
	Data string
}

// Enumeration used in assetRequest
type status int

const (
	Pending  status = iota
	Accepted status = iota
	Rejected status = iota
)

// Asset used to track the data requests and their status
type assetRequest struct {
	RequestId int64
	Applicant string
	DataId    string
	Status    status
}

// ============================================================================

// Initializes chaincode
// =====================
func (c *Chaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("Init running.")
	return shim.Success(nil)
}

// Invoke
// ======
func (c *Chaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("Invoke is running " + function)

	switch function {
	case "insertData":
		return c.insertData(stub, args)
	case "removeData":
		return c.removeData(stub, args)
	case "viewAllData":
		return c.viewAllData(stub, args)
	case "viewPersonalData":
		return c.viewPersonalData(stub, args)
	case "requestData":
		return c.requestData(stub, args)
	case "viewSharingRequests":
		return c.viewSharingRequests(stub, args)
	case "acceptRequest":
		return c.acceptRequest(stub, args)
	case "denyRequest":
		return c.denyRequest(stub, args)
	default:
		fmt.Println("Unknown function!")
		return shim.Error("Received unknown function")
	}
}

// insertData
// ==========
func (c *Chaincode) insertData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	type dataTransientInput struct {
		Name        string
		Owner       string
		Description string
		Data        string
	}

	var err error
	var dataInput dataTransientInput

	// No parameter shall be passed outside the transient map
	if len(args) != 0 {
		return shim.Error("Incorrect number of parameters. Data must be passed in transient map.")
	}

	// Retrieve the transient data
	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	// Get the 'data' field
	dataJSONBytes, ok := transMap["data"]
	if !ok {
		return shim.Error("'data' must be a key in the transient map.")
	}

	// Decode the JSON bytes and store it in a variable
	err = json.Unmarshal(dataJSONBytes, &dataInput)
	if err != nil {
		return shim.Error("Error decoding JSON data: " + string(dataJSONBytes))
	}

	// Check input consistency
	if len(dataInput.Data) == 0 {
		return shim.Error("'Data' field must be a non-empty string.")
	}
	if len(dataInput.Name) == 0 {
		return shim.Error("'Name' field must be a non-empty string.")
	}
	if len(dataInput.Description) == 0 {
		return shim.Error("'Description' field must be a non-empty string.")
	}
	if len(dataInput.Owner) == 0 {
		return shim.Error("'Owner' field must be a non-empty string.")
	}

	// Check if data already exists
	dataLedgerBytes, err := stub.GetState(dataInput.Name)
	if err != nil {
		return shim.Error("Failed to get data from the ledger: " + err.Error())
	} else if dataLedgerBytes != nil {
		fmt.Println("This data already exists: " + dataInput.Name)
		return shim.Error("This data already exists: " + dataInput.Name)
	}

	// Create data to be inserted into the ledger
	dataDesc := &dataDescription{
		Id:          dataInput.Name,
		Description: dataInput.Description,
	}

	dataProp := &dataProperty{
		Id:    dataInput.Name,
		Owner: dataInput.Owner,
	}

	dataDescJSON, err := json.Marshal(dataDesc)
	if err != nil {
		return shim.Error("Error creating data:" + err.Error())
	}

	dataPropJSON, err := json.Marshal(dataProp)
	if err != nil {
		return shim.Error("Error creating data:" + err.Error())
	}

	// Save data into the ledger
	err = stub.PutState(dataInput.Name, dataDescJSON)
	if err != nil {
		return shim.Error("Error during put state: " + err.Error())
	}

	err = stub.PutState(dataInput.Name, dataPropJSON)
	if err != nil {
		return shim.Error("Error during put state: " + err.Error())
	}

	// Create data to be insterted into the private data
	dataBio := &dataBioPrivateDetails{
		Id:   dataInput.Name,
		Data: dataInput.Data,
	}

	dataBioJSON, err := json.Marshal(dataBio)
	if err != nil {
		return shim.Error("Error creating data: " + err.Error())
	}

	err = stub.PutPrivateData("collectionDatoBioPrivateDetails", dataInput.Name, dataBioJSON)
	if err != nil {
		return shim.Error("Error during put private state: " + err.Error())
	}

	fmt.Println("end insertData")
	return shim.Success(nil)
}

// removeData
// ==========
func (c *Chaincode) removeData(stub shim.ChaincodeStubInterface, args []string) pb.Response

// viewAllData
// ========
func (c *Chaincode) viewAllData(stub shim.ChaincodeStubInterface, args []string) pb.Response

// viewPersonalData
// ========
func (c *Chaincode) viewPersonalData(stub shim.ChaincodeStubInterface, args []string) pb.Response

// requestData
// ===========
func (c *Chaincode) requestData(stub shim.ChaincodeStubInterface, args []string) pb.Response

// viewSharingRequests
// ===================
func (c *Chaincode) viewSharingRequests(stub shim.ChaincodeStubInterface, args []string) pb.Response

// acceptRequest
// =============
func (c *Chaincode) acceptRequest(stub shim.ChaincodeStubInterface, args []string) pb.Response

// denyRequest
// ===========
func (c *Chaincode) denyRequest(stub shim.ChaincodeStubInterface, args []string) pb.Response

// Main
// ====
func main() {
	err := shim.Start(&Chaincode{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Exiting Simple chaincode: %s", err)
		os.Exit(2)
	}
}
