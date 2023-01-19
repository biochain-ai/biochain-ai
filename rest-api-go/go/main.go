package main

import (
	"fmt"
	"rest-api-go/web"
)

func main() {
	//Initialize setup for Org1
	cryptoPath := "./../../keyfiles/peerOrganizations/parma.com"
	orgConfig := web.OrgSetup{
		OrgName:      "parma.com",
		MSPID:        "parma-com",
		CertPath:     cryptoPath + "/users/Admin@parma.com/msp/signcerts/Admin@parma.com-cert.pem",
		KeyPath:      cryptoPath + "/users/Admin@parma.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/tizio.parma.com/tls/ca.crt",
		PeerEndpoint: "0.0.0.0:7051",
		GatewayPeer:  "tizio.parma.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for "+orgConfig.OrgName+": ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}
