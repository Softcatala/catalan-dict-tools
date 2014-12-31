#!/bin/bash
rm lt/*
echo "Adjectius: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl diccionari-arrel/noms-fdic.txt lt/noms-lt.txt
echo "Noms: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl diccionari-arrel/adjectius-fdic.txt lt/adjectius-lt.txt
echo "Verbs: de FDIC a LT..."
perl fdic-to-lt/conjuga-verbs.pl diccionari-arrel/verbs-fdic.txt lt/verbs-lt.txt diccionari-arrel/models-verbals/
cp diccionari-arrel/*-lt.txt lt/
cat lt/*-lt.txt > lt/diccionari.txt
rm lt/*-lt.txt
# sort
export LC_ALL=C && sort -u lt/diccionari.txt > lt/diccionari_sorted.txt
rm lt/diccionari.txt
mv lt/diccionari_sorted.txt lt/diccionari.txt

#diff
diff lt/diccionari.txt ~/diccionaris/catalan-dict-lt/diccionari.txt > lt/diff.txt
echo "FET!"
ls lt

