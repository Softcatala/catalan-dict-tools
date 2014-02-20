#!/bin/bash
cd compara
cp ../fdic-to-lt/noms-lt.txt .
cp ../fdic-to-lt/adjectius-lt.txt .
cp ../fdic-to-lt/verbs-lt.txt .
cp ../lt-separat/noms.txt .
cp ../lt-separat/adjectius.txt .
cp ../lt-separat/verbs.txt .
echo "*** DIFERÈNCIES ***" > diff.txt
echo "** Compara noms **" >> diff.txt
./compara.sh noms.txt noms-lt.txt >> diff.txt
echo "** Compara noms **" >> diff.txt
./compara.sh adjectius.txt adjectius-lt.txt >> diff.txt
echo "** Compara verbs **" >> diff.txt
./compara.sh verbs.txt verbs-lt.txt >> diff.txt
cd ..