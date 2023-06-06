##### Setting the identity
curl --request GET --url 'http://localhost:3000/bootstrap?org=brescia&msp=BresciaMSP&port=7051'

##### Query the ledger
curl --request GET   --url 'http://localhost:3000/query?channelid=channel1&chaincodeid=biosharing&function=viewCatalogue' 
