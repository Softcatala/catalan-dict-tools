#!/bin/bash
cd lt-to-fdic
echo "Adjectius: de LT a FDIC..."
perl lt-to-fdic.pl adjectius
echo "Noms: de LT a FDIC..."
perl lt-to-fdic.pl noms
echo "Verbs: de LT a FDIC..."
perl extrau-verbs-i-models.pl
cd ..
