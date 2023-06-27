# Rest Api logic
This file will describe how the rest api behave during its execution. In 
particular will be explained what kind of data need to be present in the 
blockchain before and after the call. All the logic of the application will
be encoded in this server that will communicate with the different smart 
contracts in a way described here. This is done in order to simplify the 
creation and the use of chaincodes, since they do not have to make calls to 
eachother but this server will take care of everything instead.

All the possible request must be perform using an HTTP POST request, passing 
the necessary data using data fields in a Json format. All the others HTTP 
methods are refused by the server.
## Rest Endpoints
 - insertData
 - removeData
 - getPrivateData
 - requestData
 - viewCatalogue
 - viewPersonalData
 - viewRequests
 - viewAllRequests
 - managerequest
 - addUser
 - removeUser
 - checkExistence
 - viewAllUsers
 - setOrgLevel
 - createOrg
 - removeOrg
 - addToken
 - removeToken
 - seeToken

### insertData
It allows to insert data into public ledger and into the private collection
of the organization performing the call.
### removeData
It allows to remove data from the ledger and from the private collection of the 
owner's organization. 
This call must check if the selected resource is in a pending state inside of 
a request. In that case the request must be modified to describe the deletion 
of the corresponding data.
### getPrivateData
It allws to see/retrieve the private data stored inside the private collection
of the organization. 
### requestData
It allows a user to create a sharing request for a data stored into the ledger.
The request will be managed by one of the users that belongs to the organization
that owns the resource.
### viewCatalogue
It returns all the public data stored into the blockchain.
This call can be performed by all the users that can access the platform. 
The user must be register into the ledger from another user.
### viewPersonalData
It allows to see all the public data belonging to the caller's organization.
### viewRequests
It allows to see all the pending requests belonging to the caller organization.
### viewAllRequests
It allows to see all the past and present requests.
### managerequest
It allows to accept or deny a sharing requests. The caller must be the owner of
the resource being requested.

### addUser
It allows to add a new user in the ledger. The related organization must already
exist before the creation.
### removeUser
It allows to remove an existing user from the ledger.
### checkExistence
It allows to check if a user is already registered inside the ledger. If it is
present it is returned of else nothing is returned.
### viewAllUsers
It allows to retieve the list of all the users registered inside the ledger.
### setOrgLevel
It allows to change the organization level of one organization.
### createOrg
It allows to create a new organization.
### removeOrg
It allows to remove an organization. This deletes all the users related to it.
### addToken
This method allows to add a token into the active token list. This list is used to keep track of all the users logged in.
### removeToken
It alloes to remove a token at the and of the session. The token must be
present in the list to be removed.

### seeToken
This is a DEBUG endpoint. It is used to print into the Rest server console
the list of all the token related to the users logged in.
