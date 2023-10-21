#!/bin/bash

echo "Construint llista de paraules des del diccionari LT: valencià..."
perl wordlist.pl ../resultats/lt/diccionari.txt ../resultats/hunspell/catalan-valencia.aff ./extra-spelling-1.txt

sort -u ./extra-spelling-1.txt -o ./extra-spelling-2.txt

perl select-frequent.pl


sed -i '/^$/d' extra-spelling.txt
rm ./extra-spelling-1.txt
rm ./extra-spelling-2.txt