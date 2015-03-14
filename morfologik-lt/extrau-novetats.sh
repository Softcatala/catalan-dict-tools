#!/bin/bash

###
# Extrau les novetats introduïdes en el diccionari LT
# respecte a l'última versió compilada
###

cp catalan_lt.txt diccionari_antic.txt
echo "Preparant diccionari"
sed -i 's/^\(.*\)\t\(.*\)\t\(.*\)_.$/\1 \2 \3/' diccionari_antic.txt
echo "Ordenant diccionari"
export LC_ALL=C && sort -u diccionari_antic.txt -o diccionari_antic.txt
echo "Comparant diccionaris"
diff ../resultats/lt/diccionari.txt diccionari_antic.txt > diff.txt
cp diff.txt novetats_amb_tag.txt
echo "Extraient novetats"
sed -i 's/^[^<].*$//g' novetats_amb_tag.txt
sed -i 's/^< //g' novetats_amb_tag.txt
sed -i 's/ /\t/g' novetats_amb_tag.txt
sed -i '/^\s*$/d' novetats_amb_tag.txt
cp novetats_amb_tag.txt novetats_sense_tag.txt
sed -i 's/^\(.*\)\t\(.*\)\t\(.*\)$/\1/' novetats_sense_tag.txt
sed -i '/^\s*$/d' novetats_sense_tag.txt
export LC_ALL=C && sort -u novetats_sense_tag.txt -o novetats_sense_tag.txt
echo "Resultats en novetats_amb_tag.txt novetats_sense_tag.txt"
emacs novetats_* &
