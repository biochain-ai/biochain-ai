package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

// Logger
// var logger = shim.NewLogger("Chaincode_User-Logger")

// Chaincode struct
type Chaincode_User struct {
}

// Asset used to store users information
//
//   - Mail: Mail
//   - Org: Organization name
//   - CommonName: Name of the user
//   - Level: Auth level of the user (NOT USED)
type user struct {
	Mail       string
	Org        string
	CommonName string
	Level      string
}

// Asset used to store Organizations information
//
//   - Org: Organization name
//   - Level: Auth level of the organization
// type org struct {
// 	Org   string
// 	Level int
// }

// # Init
func (c *Chaincode_User) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("Calling Init function...")

	return shim.Success(nil)
}

// # Invoke
func (c *Chaincode_User) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("Invoke is running " + function)

	switch function {
	case "addUser":
		return c.addUser(stub, args)
	case "removeUser":
		return c.removeUser(stub, args)
	case "checkExistence":
		return c.checkExistence(stub, args)
	case "viewAllUsers":
		return c.viewAllUsers(stub, args)
	case "setOrgLevel":
		return c.setOrgLevel(stub, args)
	case "createOrg":
		return c.createOrg(stub, args)
	case "removeOrg":
		return c.removeOrg(stub, args)
	default:
		fmt.Println("Unknown function!")
		return shim.Error("Received unknown function")
	}
}

// # addUser
//
// It allows to store a new user.
func (c *Chaincode_User) addUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//fmt.Println("Calling addUser function...")
	// logger.Debugf("Calling addUser function...")

	var dataInput user

	// Data must be passed with transient data
	if len(args) != 0 {
		return shim.Error("Data must be passed with transient data.")
	}

	// Retrieve transient data
	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient data")
	}

	// Get the 'data' field
	dataJsonBytes, ok := transMap["data"]
	if !ok {
		return shim.Error("'data' must be a key in the transient map.")
	}

	// Unmarshal transient data
	err = json.Unmarshal(dataJsonBytes, &dataInput)
	if err != nil {
		return shim.Error("Error decoding JSON data: " + string(dataJsonBytes))
	}

	// Check input consistency
	if len(dataInput.Mail) == 0 {
		return shim.Error("'Mail' field must be a non-empty string.")
	}
	if len(dataInput.Org) == 0 {
		return shim.Error("'Org' field must be a non-empty string.")
	}
	if len(dataInput.CommonName) == 0 {
		return shim.Error("'CommonName' field must be a non-empty string.")
	}

	// Check user existence (must miss)
	dataByte, err := stub.GetState("USER" + dataInput.Mail)
	if err != nil {
		return shim.Error("Failed to get data from the ledger " + err.Error())
	} else if dataByte != nil {
		return shim.Error("User " + dataInput.Mail + " found. Cannot add it twice!")
	}

	// Check org existence (must exist)
	orgByte, err := stub.GetState("ORG" + dataInput.Org)
	if err != nil {
		return shim.Error("Failed to get data from the ledger " + err.Error())
	} else if orgByte != nil {
		return shim.Error("Org " + dataInput.Org + " not found. User cannot be add with unknown organization.")
	}

	fmt.Println(dataInput)
	// Marshall the data to be inserted into the ledger
	dataToInsertJSON, err := json.Marshal(dataInput)
	if err != nil {
		return shim.Error("Error during data marshal!")
	}

	// Save data into the ledger
	err = stub.PutState("USER"+dataInput.Mail, dataToInsertJSON)
	if err != nil {
		return shim.Error("Error during put state: " + err.Error())
	}

	fmt.Println("end addUser.")
	return shim.Success(nil)
}

// # removeUser
//
// It allows to remove an existing user.
func (c *Chaincode_User) removeUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//fmt.Println("Calling removeUser function...")
	// logger.Debugf("Calling removeUser function...")

	return shim.Success(nil)
}

// # checkExistence
//
// Allows to control the presence of a user.
//
// Check if the provided email is already registered into the ledger.
// If the User is found, it is returned, otherwise 'nil' is returned.
func (c *Chaincode_User) checkExistence(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//fmt.Println("Calling checkExistence function...")
	// logger.Debugf("Calling checkExistence function...")

	// Check argument consistency
	if len(args) != 1 {
		return shim.Error("Incorrect number of parameters. Expecting 1.")
	}

	// Print the provided argument
	fmt.Println("Args: " + args[0])

	// Perform a ledger query
	dataByte, err := stub.GetState("USER" + args[0])
	if err != nil {
		return shim.Error("Failed to get data from the ledger " + err.Error())
	}

	fmt.Println(string(dataByte))

	if dataByte == nil {
		// If not found return nil
		return shim.Success(nil)
	} else {
		var retrievedUser user
		err = json.Unmarshal(dataByte, &retrievedUser)
		if err != nil {
			return shim.Error("Error during data unmarshal.")
		}

		// if found return the user information
		return shim.Success([]byte(dataByte))
	}
}

// # viewAllUsers
//
// Allows to see all the users registered inside the ledger.
func (c *Chaincode_User) viewAllUsers(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// logger.Debugf("Calling viewAllUsers function...")

	// Perform the range query
	resultIterator, err := stub.GetStateByRange("USER", "")
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

		// Check if the retrieved key-value pair is about the DATA type
		if strings.Contains(queryResponse.Key, "USER") {
			buffer.WriteString(
				fmt.Sprintf(`{"Key":"%s", "Record":"%s"}`,
					queryResponse.Key, queryResponse.Value),
			)
			bArrayMemberAlreadyWritten = true
		}

	}
	buffer.WriteString("]")

	fmt.Printf("- viewAllUsers Result:\n%s\n", buffer.String())

	return shim.Success([]byte(buffer.String()))
}

// # setOrgLevel
//
// Allows to set the authorization level of an organization
//
//	TODO: add controls for level change
func (c *Chaincode_User) setOrgLevel(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// logger.Debugf("Calling setOrgLevel function...")

	// Check number of parameters
	if len(args) != 2 {
		return shim.Error("Wrong number of parameters. Expected two!")
	}

	// logger.Debugf("args[0]: " + args[0] + "; args[1]: " + args[1])

	org := args[0]
	newLevel := args[1]

	// Retrieve the original organization level
	orgLevelBytes, err := stub.GetState("ORG" + org)

	var originalOrgLevel string

	// Unmarshal original level
	err = json.Unmarshal(orgLevelBytes, &originalOrgLevel)
	if err != nil {
		return shim.Error("Error unmarshaling data.")
	}

	// Chech if levels are equal, done!
	if originalOrgLevel == newLevel {
		return shim.Success(nil)
	} else {
		newLevelBytes, err := json.Marshal(newLevel)
		if err != nil {
			return shim.Error("Error during data marshal.")
		}

		key := "ORG" + org

		// Store the new org level into the ledger
		err = stub.PutState(key, newLevelBytes)
		if err != nil {
			return shim.Error("Error during the putState!")
		}
	}

	return shim.Success(nil)

}

// # createOrg
//
// Add a new organization into the ledger
func (c *Chaincode_User) createOrg(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	// Check number of parameters
	if len(args) != 1 {
		return shim.Error("Wrong number of parameters. Expecting one!")
	}

	// Key to query the ledger
	key := "ORG" + args[0]
	fmt.Println("Key: " + key)

	// Check if the organization already exists
	orgBytes, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error retrieving data from the ledger.")
	}

	if orgBytes != nil {
		return shim.Error(key + " already exists. Cannot be created twice.")
	}

	level := "0"
	levelBytes, err := json.Marshal(level)
	if err != nil {
		return shim.Error("Error during data marshal.")
	}

	// Insert new org into the ledger
	err = stub.PutState(key, levelBytes)
	if err != nil {
		return shim.Error("Error during the PutState.")
	}

	return shim.Success(nil)
}

// # removeOrg
//
// Remove an existing organization from the ledger
func (c *Chaincode_User) removeOrg(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	// Check number of parameters
	if len(args) != 1 {
		return shim.Error("Wrong number of parameters. Expecting one!")
	}

	// Key to query the ledger
	key := "ORG" + args[0]

	// Check if the organization exists
	orgBytes, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error retrieving data from the ledger.")
	}

	if orgBytes == nil {
		return shim.Error(key + " does not exist. Cannot be removed.")
	}

	// Remove the organization from the ledger
	err = stub.DelState(key)
	if err != nil {
		return shim.Error("Error deleting the element.")
	}

	return shim.Success(nil)
}

// # Main
//
// Starts the chaincode.
func main() {
	// LogDebug, LogInfo, LogNotice, LogWarning, LogError, LogCritical (Default: LogDebug)
	// logger.SetLevel(shim.LogInfo)

	// Set logging level
	// logLevel, _ := shim.LogLevelt("DEBUG")
	// shim.SetLoggingLevel(logLevel)

	// Start chaincode
	err := shim.Start(&Chaincode_User{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error in chaincode start: %s", err)
		os.Exit(2)
	}
}
