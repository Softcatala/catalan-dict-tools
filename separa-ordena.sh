#!/bin/bash
echo "Separant el diccionari per categories..."
cd lt-separat
perl separa-lt.pl
cd ..
cd lt-separat-reordenat
perl separa-lt.pl
cd ..
cd lt-ordenacions
./sort-lt.sh
cd ..