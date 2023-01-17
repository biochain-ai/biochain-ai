#!/bin/bash
# Script per inserire dati dentro la blockchain e fare alcuni test

echo "Script start!!"

echo "-------------------"
echo "-- Insering data --"
echo "-------------------"
DATA=$( echo '{"name":"PrimoDato","description":"descrizione del primo dato","data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )
minifab invoke -p '"insertData"' -t '{"data":"'$DATA'"}' -o mantova.com
DATA=$( echo '{"name":"SecondoDato","description":"descrizione del secondo dato","data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )
minifab invoke -p '"insertData"' -t '{"data":"'$DATA'"}' -o mantova.com
DATA=$( echo '{"name":"TerzoDato","description":"descrizione del terzo dato","data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )
minifab invoke -p '"insertData"' -t '{"data":"'$DATA'"}' -o parma.com

echo "----------------------"
echo "-- Viewing all data --"
echo "----------------------"
minifab invoke -p '"viewAllData"' -o parma.com

echo "---------------------------"
echo "-- Viewing personal data --"
echo "---------------------------"
minifab invoke -p '"viewPersonalData"' -o mantova.com

echo "------------------"
echo "-- Request data --"
echo "------------------"
minifab invoke -p '"requestData","PrimoDato"' -o parma.com

echo "--------------------------"
echo "-- View sharing request --"
echo "--------------------------"
minifab invoke -p '"viewSharingRequests"' -o mantova.com

echo "----------------------------"
echo "-- Accept sharing request --"
echo "----------------------------"
minifab invoke -p '"acceptRequest","1"'  -o mantova.com

echo "----------------------------------"
echo "-- View secret of the applicant --"
echo "----------------------------------"
minifab invoke -p '"viewSecretData"' -o parma.com

echo "Done!"
