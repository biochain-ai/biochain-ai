package web

import (
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"path"
	"strconv"
	"strings"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

// OrgSetup contains organization's config to interact with the network.
type OrgSetup struct {
	OrgName      string
	MSPID        string
	CryptoPath   string
	CertPath     string
	KeyPath      string
	TLSCertPath  string
	PeerEndpoint string
	GatewayPeer  string
	Gateway      client.Gateway
}

var setups OrgSetup

// Enumeration used in assetRequest
type status int

const (
	Pending  status = iota
	Accepted status = iota
	Rejected status = iota
)

// struct used for the sharing requests
type sharingRequest struct {
	RequestId int64
	Applicant string
	DataId    string
	Owner     string
	Status    status
}

// Struct used to retrive the elements of the viewRequest call
type sharingElement struct {
	Key    string
	Record sharingRequest
}

// Serve starts http web server.
func Serve() {
	http.HandleFunc("/bootstrap", setups.Bootstrap)
	// http.HandleFunc("/query", setups.Query)
	// http.HandleFunc("/invoke", setups.Invoke)
	// http.HandleFunc("/transient", setups.Transient)
	// http.HandleFunc("/test", setups.Test)

	//// Chaincode BIOCHAIN
	// Rest resourses that match the chaincode method
	http.HandleFunc("/insertData", setups.InsertData)
	http.HandleFunc("/removeData", setups.RemoveData)
	http.HandleFunc("/getPrivateData", setups.GetPrivateData)
	http.HandleFunc("/requestData", setups.RequestData)

	// Rest resources that does not match with the chaincode mathods
	http.HandleFunc("/view", setups.View)
	http.HandleFunc("/managerequest", setups.ManageRequest)

	//// Chaincode USER
	http.HandleFunc("/addUser", setups.addUser)
	http.HandleFunc("/removeUser", setups.removeUser)
	http.HandleFunc("/checkExistence", setups.checkExistence)
	http.HandleFunc("/viewAllUsers", setups.viewAllUsers)
	http.HandleFunc("/setOrgLevel", setups.setOrgLevel)
	http.HandleFunc("/createOrg", setups.createOrg)
	http.HandleFunc("/removeOrg", setups.removeOrg)

	fmt.Println("Listening (http://localhost:3000/)...")
	if err := http.ListenAndServe(":3000", nil); err != nil {
		fmt.Println(err)
	}
}

// Calls the methods "accept/deny" request
func (setup *OrgSetup) ManageRequest(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request to accept/deny a sharing request")

	setupCorsResponse(&w, r)

	queryParams := r.URL.Query()
	chaincodeid := "biosharing"
	channelID := "channel1"
	method := queryParams.Get("method")
	dataid := queryParams.Get("id")

	var function string
	var requesterMSPID string

	// Select the action to perform
	method = strings.ToLower(method)
	if method == "accept" {
		function = "acceptRequest"
	} else if method == "deny" {
		function = "denyRequest"
	} else {
		fmt.Println("Wrong method name")
		return
	}
	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chaincodeid)

	fmt.Printf("Executing %s", function)
	// fmt.Printf("	channel: %s, chaincode: %s, function: %s, method: %s, id: %s\n", channelID, chaincodeid, function, method, dataid)

	// Fetch with a ledger query the MSPID of the other endorser
	var sE []sharingElement
	evaluateResponse, err := contract.EvaluateTransaction("viewRequests")
	// Error check
	if err != nil {
		fmt.Fprintf(w, "Error: %s", err)
		return
	}
	// Unmarshall bytes array
	err = json.Unmarshal(evaluateResponse, &sE)
	if err != nil {
		fmt.Println("Error during data unmarshall " + err.Error())
	}

	// Convert dataid from string to integer
	dataidInt, _ := strconv.ParseInt(dataid, 10, 64)
	// Retrieve the MSPID from the request that need to be satisfied
	for e := range sE {
		if sE[e].Record.RequestId == dataidInt {
			fmt.Println(strings.Split(sE[e].Record.Applicant, "#")[1])
			requesterMSPID = strings.Split(sE[e].Record.Applicant, "#")[1]
		}
	}

	// Check MSPID correctness
	if !strings.Contains(requesterMSPID, "MSP") {
		fmt.Fprintf(w, "Error retrieving MSPID")
		return
	}

	// Submit transaction to accept sharing request
	result, err := contract.Submit(
		function,
		client.WithArguments(dataid),
		client.WithEndorsingOrganizations(setups.MSPID, requesterMSPID),
	)

	// Check for errors
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)

	}

	fmt.Println("Result: " + string(result))
}

// Calls the chaincode method 'insertData'
func (setup *OrgSetup) InsertData(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for insertData")

	setupCorsResponse(&w, r)

	// Read the body of the request
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Println("Error while reading the request body")
	}

	// Create a map with the received data
	privateData := map[string][]byte{
		"data": []byte(reqBody),
	}

	// Invoke the method with transient data
	network := setups.Gateway.GetNetwork("channel1")
	contract := network.GetContract("biosharing")
	result, err := contract.Submit(
		"insertData",
		client.WithArguments(),
		client.WithTransient(privateData),
		client.WithEndorsingOrganizations(setups.MSPID),
	)

	// Console log
	fmt.Println("Inserting data for %s", setups.MSPID)

	// Check for errors
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)

	}

	fmt.Println("Result: " + string(result))
}

// Calls the chaincode method 'removeData'
func (setup *OrgSetup) RemoveData(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Receiving request for removeData")

	setupCorsResponse(&w, r)

	// Read the body of the request
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Println("Error while reading the request body")
	}

	// Create a map with the received data
	privateData := map[string][]byte{
		"data": []byte(reqBody),
	}

	// Invoke the method with transient data
	network := setups.Gateway.GetNetwork("channel1")
	contract := network.GetContract("biosharing")
	result, err := contract.Submit(
		"removeData",
		client.WithArguments(),
		client.WithTransient(privateData),
		client.WithEndorsingOrganizations(setups.MSPID),
	)

	// Console log
	fmt.Println("Removing data for %s", setups.MSPID)

	// Check for errors
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)
	}

	fmt.Println("Result: " + string(result))
}

// Calls the 'getPrivateData' method
func (setup *OrgSetup) GetPrivateData(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for getPrivateData")

	setupCorsResponse(&w, r)

	// Set parameters
	chaincodeid := "biosharing"
	channelID := "channel1"
	function := "getPrivateData"
	fmt.Printf("	channel: %s, chaincode: %s, function: %s,\n", channelID, chaincodeid, function)
	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chaincodeid)

	// Select the function to query
	fmt.Println("Calling " + function)

	evaluateResponse, err := contract.EvaluateTransaction(function)
	// Error check
	if err != nil {
		fmt.Fprintf(w, "Error: %s", err)
		return
	}

	fmt.Fprintf(w, "Response: %s", evaluateResponse)
}

// Calls the 'requestData' method
func (setup *OrgSetup) RequestData(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for requestData")

	setupCorsResponse(&w, r)

	// Set the parameters
	queryParams := r.URL.Query()
	chainCodeName := "biosharing"
	channelID := "channel1"
	function := "requestData"
	data := queryParams.Get("data")

	fmt.Printf("	channel: %s, chaincode: %s, function: %s, data: %s\n", channelID, chainCodeName, function, data)

	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chainCodeName)

	// Call the method using the received data
	txn_proposal, err := contract.NewProposal(function, client.WithArguments(data))
	if err != nil {
		fmt.Fprintf(w, "Error creating txn proposal: %s", err)
		return
	}
	txn_endorsed, err := txn_proposal.Endorse()
	if err != nil {
		fmt.Fprintf(w, "Error endorsing txn: %s", err)
		return
	}
	txn_committed, err := txn_endorsed.Submit()
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)
		return
	}

	fmt.Fprintf(w, "Transaction ID : %s Response: %s", txn_committed.TransactionID(), txn_endorsed.Result())

}

// Calls the 'view' methods
func (setup *OrgSetup) View(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for view")

	setupCorsResponse(&w, r)

	// Set parameters
	queryParams := r.URL.Query()
	chaincodeid := "biosharing"
	channelID := "channel1"
	function := queryParams.Get("function")
	fmt.Printf("	channel: %s, chaincode: %s, function: %s,\n", channelID, chaincodeid, function)
	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chaincodeid)

	// To lower the function name
	function = strings.ToLower(function)

	// Select the function to query
	fmt.Println("Calling " + function)
	switch function {
	case "catalogue":
		evaluateResponse, err := contract.EvaluateTransaction("viewCatalogue")
		// Error check
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		fmt.Fprintf(w, "Response: %s", evaluateResponse)
		break
	case "personaldata":
		evaluateResponse, err := contract.EvaluateTransaction("viewPersonalData")
		// Error check
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		fmt.Fprintf(w, "Response: %s", evaluateResponse)
		break
	case "requests":
		evaluateResponse, err := contract.EvaluateTransaction("viewRequests")
		// Error check
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		fmt.Fprintf(w, "Response: %s", evaluateResponse)
		break
	case "allrequests":
		evaluateResponse, err := contract.EvaluateTransaction("viewAllRequests")
		// Error check
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		fmt.Fprintf(w, "Response: %s", evaluateResponse)
		break
	default:
		errorName := "Wrong method name"
		fmt.Fprintf(w, "Response: %s", errorName)
		return
	}

	fmt.Println("End view function")
}

func (setup OrgSetup) Bootstrap(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Bootstrap")

	setupCorsResponse(&w, r)

	queryParams := r.URL.Query()
	org := queryParams.Get("org")
	msp := queryParams.Get("msp")
	port := queryParams.Get("port")

	//Initialize setup for Org1
	// This settings now depend on the docker container and network settings.
	//cryptoPath := "./../../crypto-config/peerOrganizations/" + org + ".com"
	cryptoPath := "./crypto-config/peerOrganizations/" + org + ".com"
	setups = OrgSetup{
		OrgName: org + ".com",
		MSPID:   msp,
		//CertPath:     cryptoPath + "/users/Admin@" + org + ".com/msp/signcerts/cert.pem",
		CertPath:     cryptoPath + "/users/Admin@" + org + ".com/msp/signcerts/Admin@" + org + ".com-cert.pem",
		KeyPath:      cryptoPath + "/users/Admin@" + org + ".com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/peer0." + org + ".com/tls/ca.crt",
		GatewayPeer:  "peer0." + org + ".com",
		PeerEndpoint: "peer0." + org + ".com" + ":" + port,
		//PeerEndpoint: "peer0.parma.com:" + port,

	}

	err := setups.Initialize()
	if err != nil {
		fmt.Println("Error initializing setup for "+setups.OrgName+": ", err)
	}
}

// Initialize the setup for the organization.
func (setup OrgSetup) Initialize() error {
	log.Printf("Initializing connection for %s...\n", setups.OrgName)
	clientConnection := setups.newGrpcConnection()
	id := setups.newIdentity()
	sign := setups.newSign()

	gateway, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	setups.Gateway = *gateway
	log.Println("Initialization complete")
	log.Println(setups.OrgName + "\n" + setups.MSPID + "\n" + setups.PeerEndpoint + "\n" + setups.GatewayPeer + "\n")
	log.Println(setups.Gateway)
	return nil
}

// // Chaincode USER
func (setup *OrgSetup) addUser(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for addUser")

	setupCorsResponse(&w, r)

	// Read the body of the request
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Println("Error while reading the request body")
	}

	// Create a map with the received data
	privateData := map[string][]byte{
		"data": []byte(reqBody),
	}

	// Invoke the method with transient data
	network := setups.Gateway.GetNetwork("channel1")
	contract := network.GetContract("user")
	result, err := contract.Submit(
		"addUser",
		client.WithArguments(),
		client.WithTransient(privateData),
		client.WithEndorsingOrganizations(setups.MSPID),
	)

	// Console log
	fmt.Println("Inserting data for %s", setups.MSPID)

	// Check for errors
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)

	}

	fmt.Println("Result: " + string(result))
}

func (setup *OrgSetup) removeUser(w http.ResponseWriter, r *http.Request) {
	// TODO
}

func (setup *OrgSetup) checkExistence(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for checkExistence")

	setupCorsResponse(&w, r)

	// Set the parameters
	queryParams := r.URL.Query()
	chainCodeName := "user"
	channelID := "channel1"
	function := "checkExistence"
	data := queryParams.Get("data")

	fmt.Printf("	channel: %s, chaincode: %s, function: %s, data: %s\n", channelID, chainCodeName, function, data)

	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chainCodeName)

	// Call the method using the received data
	txn_proposal, err := contract.NewProposal(function, client.WithArguments(data))
	if err != nil {
		fmt.Fprintf(w, "Error creating txn proposal: %s", err)
		return
	}
	txn_endorsed, err := txn_proposal.Endorse()
	if err != nil {
		fmt.Fprintf(w, "Error endorsing txn: %s", err)
		return
	}
	txn_committed, err := txn_endorsed.Submit()
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)
		return
	}

	fmt.Fprintf(w, "Transaction ID : %s Response: %s", txn_committed.TransactionID(), txn_endorsed.Result())

}

func (setup *OrgSetup) viewAllUsers(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for viewAllUsers")

	setupCorsResponse(&w, r)

	// Set parameters
	chaincodeid := "user"
	channelID := "channel1"
	//function := queryParams.Get("function")
	fmt.Printf("	channel: %s, chaincode: %s\n", channelID, chaincodeid)
	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chaincodeid)

	// Select the function to query
	evaluateResponse, err := contract.EvaluateTransaction("viewAllUsers")
	// Error check
	if err != nil {
		fmt.Fprintf(w, "Error: %s", err)
		return
	}

	fmt.Fprintf(w, "Response: %s", evaluateResponse)
}

func (setup *OrgSetup) setOrgLevel(w http.ResponseWriter, r *http.Request) {
	// TODO
}

// Calls the 'createOrg' method
func (setup *OrgSetup) createOrg(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for createOrg")

	setupCorsResponse(&w, r)

	// Set the parameters
	queryParams := r.URL.Query()
	chainCodeName := "user"
	channelID := "channel1"
	function := "createOrg"
	data := queryParams.Get("data")

	fmt.Printf("	channel: %s, chaincode: %s, function: %s, data: %s\n", channelID, chainCodeName, function, data)

	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chainCodeName)

	// Call the method using the received data
	txn_proposal, err := contract.NewProposal(function, client.WithArguments(data))
	if err != nil {
		fmt.Fprintf(w, "Error creating txn proposal: %s", err)
		return
	}
	txn_endorsed, err := txn_proposal.Endorse()
	if err != nil {
		fmt.Fprintf(w, "Error endorsing txn: %s", err)
		return
	}
	txn_committed, err := txn_endorsed.Submit()
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)
		return
	}

	fmt.Fprintf(w, "Transaction ID : %s Response: %s", txn_committed.TransactionID(), txn_endorsed.Result())
}

// Calls the 'removeOrg' method
func (setup *OrgSetup) removeOrg(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received request for removeOrg")

	setupCorsResponse(&w, r)

	// Set the parameters
	queryParams := r.URL.Query()
	chainCodeName := "user"
	channelID := "channel1"
	function := "removeOrg"
	data := queryParams.Get("data")

	fmt.Printf("	channel: %s, chaincode: %s, function: %s, data: %s\n", channelID, chainCodeName, function, data)

	network := setups.Gateway.GetNetwork(channelID)
	contract := network.GetContract(chainCodeName)

	// Call the method using the received data
	txn_proposal, err := contract.NewProposal(function, client.WithArguments(data))
	if err != nil {
		fmt.Fprintf(w, "Error creating txn proposal: %s", err)
		return
	}
	txn_endorsed, err := txn_proposal.Endorse()
	if err != nil {
		fmt.Fprintf(w, "Error endorsing txn: %s", err)
		return
	}
	txn_committed, err := txn_endorsed.Submit()
	if err != nil {
		fmt.Fprintf(w, "Error submitting transaction: %s", err)
		return
	}

	fmt.Fprintf(w, "Transaction ID : %s Response: %s", txn_committed.TransactionID(), txn_endorsed.Result())
}

// //////////////////////////////////////////////////////////////////////////////
// newGrpcConnection creates a gRPC connection to the Gateway server.
func (setup OrgSetup) newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(setup.TLSCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, setup.GatewayPeer)

	connection, err := grpc.Dial(setup.PeerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

// newIdentity creates a client identity for this Gateway connection using an X.509 certificate.
func (setup OrgSetup) newIdentity() *identity.X509Identity {
	certificate, err := loadCertificate(setup.CertPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(setup.MSPID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

// newSign creates a function that generates a digital signature from a message digest using a private key.
func (setup OrgSetup) newSign() identity.Sign {
	files, err := ioutil.ReadDir(setup.KeyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := ioutil.ReadFile(path.Join(setup.KeyPath, files[0].Name()))

	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

// # setupCorsResponse
//
// Allows to manage Cors response
func setupCorsResponse(w *http.ResponseWriter, r *http.Request) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Authorization")
}
