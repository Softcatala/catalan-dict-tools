#!/bin/bash

echo "Construint llista de paraules des del diccionari LT: valencià..."
perl wordlist.pl ../resultats/lt/dicc.txt ../resultats/hunspell/catalan-valencia.aff ./extra-spelling-1.txt

sort -u ./extra-spelling-1.txt -o ./extra-spelling-2.txt

