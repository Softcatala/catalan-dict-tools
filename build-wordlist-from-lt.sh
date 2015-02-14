#!/bin/bash
perl ./wordlist/wordlist.pl ./resultats/lt/diccionari.txt ./resultats/hunspell/catalan-valencia.aff ./resultats/wordlist/wordlist.txt
cat fdic-to-hunspell/dades/extres.dic >> ./resultats/wordlist/wordlist.txt