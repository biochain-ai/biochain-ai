#!/bin/bash
# Script per costruire la rete e installare il chiancode 'privatedata'

echo "Inizio Script!!"

echo " ---------------------------"
echo " -- Starting the network -- "
echo " ---------------------------"
minifab up -o parma.com

echo "------------------"
echo "-- Copying code --"
echo "------------------"
cp -R ~/_uni/borsa/biochain-ai/privatedata/ ~/minifab/vars/chaincode/

echo "--------------------------"
echo "-- Installing chaincode --"
echo "--------------------------"
minifab install -n privatedata -r true

echo "------------------------------"
echo "-- Replacing words with sed --"
echo "------------------------------"
sed -i 's/collectionPublic/collectionDatoBio/g' vars/privatedata_collection_config.json
sed -i 's/collectionPrivate/collectionDatoBioPrivateDetails/g' vars/privatedata_collection_config.json

echo "-------------------------------"
echo "-- Approve,commit,initialize --"
echo "-------------------------------"
minifab approve,commit,initialize -p ''
