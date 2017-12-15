#!/bin/bash

dir_resultat="resultats/lt"

#DNV
echo "Adjectius, noms i adverbis (DNV): de FDIC a LT..."
perl fdic-to-lt/flexiona.pl diccionari-arrel/dnv-fdic.txt $dir_resultat/noms-adj-adv-lt.txt
echo "Verbs (DNV): de FDIC a LT..."
perl fdic-to-lt/conjuga-verbs.pl diccionari-arrel/dnv-fdic.txt $dir_resultat/verbs-lt.txt diccionari-arrel/models-verbals/

cat $dir_resultat/*-lt.txt > $dir_resultat/diccionari-dnv.txt
rm $dir_resultat/*-lt.txt
# sort
export LC_ALL=C && sort -u $dir_resultat/diccionari-dnv.txt > $dir_resultat/diccionari_sorted.txt
rm $dir_resultat/diccionari-dnv.txt
mv $dir_resultat/diccionari_sorted.txt $dir_resultat/diccionari-dnv.txt

echo "Resultat en el directori $dir_resultat"
echo "FET!"

