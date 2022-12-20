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
	Id           string
	Proprietario string
}

// Asset used to describe the data
type dataDescription struct {
	Id          string
	Description string
}

// Asset used in the private databases to store the actual data
type datoBioPrivateDetails struct {
	Id   string
	Dato string
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
	fmt.Println("invoke is running " + function)

	switch function {
	case "inserisciDato":
		return c.inserisciDato(stub, args)
	default:
		fmt.Println("Funzione non esistente!")
		return shim.Error("Received unknown function")
	}
}

// insertData
// ==========
func (c *Chaincode) insertData(stub shim.ChaincodeStubInterface) pb.Response

// removeData
// ==========
func (c *Chaincode) removeData(stub shim.ChaincodeStubInterface) pb.Response

// viewAllData
// ========
func (c *Chaincode) viewAllData(stub shim.ChaincodeStubInterface) pb.Response

// viewPersonalData
// ========
func (c *Chaincode) viewPersonalData(stub shim.ChaincodeStubInterface) pb.Response

// requestData
// ===========
func (c *Chaincode) requestData(stub shim.ChaincodeStubInterface) pb.Response

// viewSharingRequests
// ===================
func (c *Chaincode) viewSharingRequests(stub shim.ChaincodeStubInterface) pb.Response

// acceptRequest
// =============
func (c *Chaincode) acceptRequest(stub shim.ChaincodeStubInterface) pb.Response

// denyRequest
// ===========
func (c *Chaincode) denyRequest(stub shim.ChaincodeStubInterface) pb.Response

func (c *Chaincode) inserisciDato(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	type datoTransientInput struct {
		Nome         string
		Proprietario string
		Dato         string
	}

	if len(args) != 0 {
		return shim.Error("Incorrect number of parameters. Data must be passed in transient map.")
	}

	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	marbleJsonBytes, ok := transMap["dato"]
	if !ok {
		return shim.Error("dato must be a key in the transient map")
	}

	if len(marbleJsonBytes) == 0 {
		return shim.Error("dato value in the transient map must be a non-empty JSON string")
	}

	var datoInput datoTransientInput
	err = json.Unmarshal(marbleJsonBytes, &datoInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(marbleJsonBytes))
	}

	if len(datoInput.Nome) == 0 {
		return shim.Error("Nome field must be a non-empty string")
	}
	if len(datoInput.Proprietario) == 0 {
		return shim.Error("proprietario field must be a non-empty string")
	}
	if len(datoInput.Dato) == 0 {
		return shim.Error("dato field must be a non-empty string")
	}

	// ==== Check if marble already exists ====
	datoAsBytes, err := stub.GetPrivateData("collectionDatoBio", datoInput.Nome)
	if err != nil {
		return shim.Error("Failed to get dato: " + err.Error())
	} else if datoAsBytes != nil {
		fmt.Println("This dato already exists: " + datoInput.Nome)
		return shim.Error("This dato already exists: " + datoInput.Nome)
	}

	// ==== Create marble object and marshal to JSON ====
	dato := &datoBio{
		Nome:         datoInput.Nome,
		Proprietario: datoInput.Proprietario,
	}
	datoJSONasBytes, err := json.Marshal(dato)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save marble to state ===
	err = stub.PutPrivateData("collectionDatoBio", datoInput.Nome, datoJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== Create marble private details object with price, marshal to JSON, and save to state ====
	datoBioPrivateDetails := &datoBioPrivateDetails{
		Nome: datoInput.Nome,
		Dato: datoInput.Dato,
	}
	datoBioPrivateDetailsBytes, err := json.Marshal(datoBioPrivateDetails)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutPrivateData("collectionDatoBioPrivateDetails", datoInput.Nome, datoBioPrivateDetailsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end init marble")
	return shim.Success(nil)
}

// Main
// ====
func main() {
	err := shim.Start(&Chaincode{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Exiting Simple chaincode: %s", err)
		os.Exit(2)
	}
}
