#!/bin/bash
cd fdic-to-lt
echo "Adjectius: de FDIC a LT..."
perl flexiona.pl noms
echo "Noms: de FDIC a LT..."
perl flexiona.pl adjectius
echo "Verbs: de FDIC a LT..."
perl conjuga-verbs.pl
cd ..
