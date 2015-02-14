#!/bin/bash
perl ./wordlist/wordlist.pl ./resultats/lt/diccionari.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/wordlist/wordlist.txt
cat fdic-to-hunspell/dades/extres.dic >> ./resultats/wordlist/wordlist.txt
export LC_ALL=C && sort -u ./resultats/wordlist/wordlist.txt -o ./resultats/wordlist/wordlist.txt