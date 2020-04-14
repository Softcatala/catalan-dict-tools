#!/bin/bash
echo "Construint llista de paraules des del diccionari LT..."

perl ./wordlist/wordlist.pl ./resultats/lt/diccionari.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/spelling/ca-ES.txt
cat fdic-to-hunspell/dades/extres.dic >> ./resultats/spelling/ca-ES.txt
export LC_ALL=C && sort -u ./resultats/spelling/ca-ES.txt -o ./resultats/spelling/ca-ES.txt
sed -i -E 's/\s+$//' ./resultats/spelling/ca-ES.txt
sed -i '/^$/d' ./resultats/spelling/ca-ES.txt

echo "Construint llista de paraules des del diccionari LT: valencià..."
perl ./wordlist/wordlist.pl ./resultats/lt/dicc.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/spelling/ca-ES-valencia.txt
cat fdic-to-hunspell/dades/extres.dic >> ./resultats/spelling/ca-ES-valencia.txt
export LC_ALL=C && sort -u ./resultats/spelling/ca-ES-valencia.txt -o ./resultats/spelling/ca-ES-valencia.txt
sed -i -E 's/\s+$//' ./resultats/spelling/ca-ES-valencia.txt
sed -i '/^$/d' ./resultats/spelling/ca-ES-valencia.txt