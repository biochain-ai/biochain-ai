#!/bin/bash
# Script per spegnere la rete e cancellare tutti file creati durante l'esecuzione

echo "Inizio Script!!"

echo "--------------"
echo "-- Shutdown --"
echo "--------------"

minifab down
minifab cleanup

echo "Done!"
