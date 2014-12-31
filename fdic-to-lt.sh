#!/bin/bash
echo "Adjectius: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl lt-to-fdic/noms-fdic.txt fdic-to-lt/noms-lt.txt
echo "Noms: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl lt-to-fdic/adjectius-fdic.txt fdic-to-lt/adjectius-lt.txt
echo "Verbs: de FDIC a LT..."
perl fdic-to-lt/conjuga-verbs.pl lt-to-fdic/verbs-fdic.txt fdic-to-lt/verbs-lt.txt lt-to-fdic/models-verbals/
cd ..
