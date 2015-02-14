#!/bin/bash
dir_resultat="resultats/lt"
rm $dir_resultat/*
echo "Adjectius: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl diccionari-arrel/noms-fdic.txt $dir_resultat/noms-lt.txt
echo "Noms: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl diccionari-arrel/adjectius-fdic.txt $dir_resultat/adjectius-lt.txt
echo "Verbs: de FDIC a LT..."
perl fdic-to-lt/conjuga-verbs.pl diccionari-arrel/verbs-fdic.txt $dir_resultat/verbs-lt.txt diccionari-arrel/models-verbals/
echo "Afegint la resta de categories..."
cp diccionari-arrel/*-lt.txt $dir_resultat
cat $dir_resultat/*-lt.txt > $dir_resultat/diccionari.txt
rm $dir_resultat/*-lt.txt
# sort
export LC_ALL=C && sort -u $dir_resultat/diccionari.txt > $dir_resultat/diccionari_sorted.txt
rm $dir_resultat/diccionari.txt
mv $dir_resultat/diccionari_sorted.txt $dir_resultat/diccionari.txt

echo "Resultat en el directori $dir_resultat"
echo "FET!"

