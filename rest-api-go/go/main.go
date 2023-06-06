package main

import (
	"fmt"
	"rest-api-go/web"
)

func main() {
	//Initialize setup for Org1
	// cryptoPath := "./../../crypto-config/peerOrganizations/brescia.com"
	// orgConfig := web.OrgSetup{
	// 	OrgName:      "brescia.com",
	// 	MSPID:        "BresciaMSP",
	// 	CertPath:     cryptoPath + "/users/Customuser1@brescia.com/msp/signcerts/cert.pem",
	// 	KeyPath:      cryptoPath + "/users/Customuser1@brescia.com/msp/keystore/",
	// 	TLSCertPath:  cryptoPath + "/peers/peer0.brescia.com/tls/ca.crt",
	// 	PeerEndpoint: "localhost:7051",
	// 	GatewayPeer:  "peer0.brescia.com",
	// }

	//orgSetup, err := web.Initialize(orgConfig)
	//if err != nil {
	//	fmt.Println("Error initializing setup for "+orgConfig.OrgName+": ", err)
	//}

	fmt.Println("Server starting...")

	web.Serve()

}
