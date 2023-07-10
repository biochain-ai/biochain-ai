## Chaincodes
This folder contains the chaincodes that are used into the blockchain, everyone in its own folder.

The chaincodes do not talk to eachother, the logic is all inside the REST API server.

### Biosharing
This chaincode allows the user to insert, delete and consult all the bio data in the ledger. It allows to see the private data stored inside the organization's private collaction. Furthermore it allows to ask for data to other organizations and to manage data requests accepting or denying them.

#### Functions
 - insertData: insert a data element in the blockchain, the public part in the public ledger and the private part in the private collenction of the organization.
 - removeData: delete a data element from the public ledger and the private collections.
 - viewCatalogue: view all the elements in the public ledger.
 - viewPersonalData: view all the elements in the public ledger that belongs to the organization.
 - getPrivateData: view all the elements in the private collection.
 - requestData: send a sharing request for a data owned by another organization.
 - viewRequests: view all the sharing requests for the organization.
 - acceptRequests: accept the sharing requests for a data element and copy the private part in the private collection of the requester.
 - denyRequest: deny a sharing request of a data element.
 - viewAllRequests: view all the sharing requests of all the organizations in the system.
## User
This chaincode allows to manage all the users that can work with the blockchain. It allows to insert organizations and to add and remove users.

#### Functions
 - addUser: insert a user in the ledger.
 - removeUser: delete a user from the ledger.
 - checkExistence: check if a user exists in the ledger.
 - viewAllUsers: view all the existing users.
 - setOrgLEvel: change the org level of an organization.
 - createOrg: create a new organization.
 - removeOrg: delete an existing organization.
 - viewAllOrgs: view all the existing organizations.