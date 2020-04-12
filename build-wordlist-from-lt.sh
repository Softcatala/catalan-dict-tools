#!/bin/bash
echo "Construint llista de paraules des del diccionari LT..."
#perl ./wordlist/wordlist.pl ./resultats/lt/diccionari.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/spelling/wordlist.txt
perl ./wordlist/wordlist.pl ./resultats/lt/dicc.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/spelling/wordlist.txt
cat fdic-to-hunspell/dades/extres.dic >> ./resultats/spelling/wordlist.txt
export LC_ALL=C && sort -u ./resultats/spelling/wordlist.txt -o ./resultats/spelling/wordlist.txt

sed -i -E 's/\s+$//' ./resultats/spelling/wordlist.txt
sed -i '/^$/d' ./resultats/spelling/wordlist.txt