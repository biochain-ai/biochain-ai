/*
This smartcontract will allow users to:
 - insert data into their private database
 - make requests to obtain data of other users
 - accept or deny requests from other users to share data
 - inform everyone of the data available for sharing

  More to be added
  TODO
   - check args, decide if they must be ignored if present or give error
*/

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

// Chanicode struct
type Chaincode struct {
}

// Asset used to track define data, publicly
type data struct {
	Id          string
	Owner       string
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
// Gives a set of transient data, this methods insert in the ledger the pair
// <name> - <name,descritpion,owner> and in the private collection the pair
// <name> - <data>
func (c *Chaincode) insertData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Println("- start insertData")

	type dataTransientInput struct {
		Name        string
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

	// Check if data already exists
	dataLedgerBytes, err := stub.GetState(dataInput.Name)
	if err != nil {
		return shim.Error("Failed to get data from the ledger: " + err.Error())
	} else if dataLedgerBytes != nil {
		fmt.Println("This data already exists: " + dataInput.Name)
		return shim.Error("This data already exists: " + dataInput.Name)
	}

	var creator string
	creatorBytes, _ := stub.GetCreator()
	creator = string(creatorBytes[:])

	// Create data to be inserted into the ledger
	dataToInsert := &data{
		Id:          dataInput.Name,
		Description: dataInput.Description,
		Owner:       creator,
	}

	// Marshal the data
	dataToInsertJSON, err := json.Marshal(dataToInsert)
	if err != nil {
		return shim.Error("Error creating data:" + err.Error())
	}

	// Save data into the ledger
	err = stub.PutState(dataInput.Name, dataToInsertJSON)
	if err != nil {
		return shim.Error("Error during put state: " + err.Error())
	}

	// Create data to be inserted into the private data
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
// Given a data name, using transient data, this method deletes the
// corresponding data from the ledger and from the private collection.
func (c *Chaincode) removeData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Println("- Start removeData")

	type removeDataTransientInput struct {
		Name string
	}

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

	if len(dataJSONBytes) == 0 {
		return shim.Error("'data' value in the transient map must be a non-empty JSON string.")
	}

	// Unmarshal Json data
	var removeDataInput removeDataTransientInput
	err = json.Unmarshal(dataJSONBytes, &removeDataInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(dataJSONBytes))
	}

	if len(removeDataInput.Name) == 0 {
		return shim.Error("'Name' fiels must be a non-empty string.")
	}

	// Check if data already exists
	dataBytes, err := stub.GetState(removeDataInput.Name)
	if err != nil {
		return shim.Error("Failed to get data from the ledger: " + err.Error())
	} else if dataBytes == nil {
		fmt.Println("This data does not exists: " + removeDataInput.Name)
		return shim.Error("This data cannot be removed, it does not exist!")
	}

	// Check if the one how asked for deletion is the owner
	var data data
	err = json.Unmarshal(dataBytes, &data)
	if err != nil {
		return shim.Error("Error during data unmarshal")
	}

	var creator string
	creatorBytes, _ := stub.GetCreator()
	creator = string(creatorBytes[:])

	if data.Owner != creator {
		return shim.Error("Deletion not allowed. Only the creator can delete its data.")
	}

	// Delete public state
	err = stub.DelState(removeDataInput.Name)
	if err != nil {
		return shim.Error("Error removing the key from the ledger " + err.Error())
	}

	fmt.Println("end removeData")
	return shim.Success(nil)
}

// viewAllData
// ===========
// This method returns all the key-value pairs in the ledger
func (c *Chaincode) viewAllData(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	// Check the number of arguements
	if len(args) != 0 {
		return shim.Error("Incorrect number of arguments. Zero expected")
	}

	// Perform the range query
	resultIterator, err := stub.GetStateByRange("", "")
	if err != nil {
		return shim.Error("Error during range query. " + err.Error())
	}
	defer resultIterator.Close()

	// Write result on the buffer
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultIterator.HasNext() {
		queryResponse, err := resultIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		// Add a comma before array member
		if bArrayMemberAlreadyWritten {
			buffer.WriteString(",")
		}

		buffer.WriteString(
			fmt.Sprintf(`{"Key":"%s", "Record":"%s"}`,
				queryResponse.Key, queryResponse.Value),
		)
		bArrayMemberAlreadyWritten = true

	}
	buffer.WriteString("]")

	fmt.Printf("- viewAllData Result:\n%s\n", buffer.String())

	return shim.Success([]byte(buffer.String()))
}

// viewPersonalData
// ================
func (c *Chaincode) viewPersonalData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

// requestData
// ===========
func (c *Chaincode) requestData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

// viewSharingRequests
// ===================
func (c *Chaincode) viewSharingRequests(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

// acceptRequest
// =============
func (c *Chaincode) acceptRequest(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

// denyRequest
// ===========
func (c *Chaincode) denyRequest(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

// Main
// ====
func main() {
	err := shim.Start(&Chaincode{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error in chaincode start: %s", err)
		os.Exit(2)
	}
}
