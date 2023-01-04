#!/bin/bash
# Script per inserire dati dentro la blockchain

echo "Inizio Script!!"

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

echo "Done!"
