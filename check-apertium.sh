#!/bin/bash
dir_programes="fdic-to-apertium"
original_apertium_dict="/home/jaume/apertium/apertium-cat/apertium-cat.cat.dix"
generated_apertium_adj_dict="resultats/apertium/adj-languagetool-format-apertium.txt"
generated_apertium_nom_dict="resultats/apertium/nom-languagetool-format-apertium.txt"
dir_resultat="tests-apertium"

rm -rf $dir_resultat
mkdir $dir_resultat

perl $dir_programes/check-adj-apertium.pl $original_apertium_dict $original_apertium_dict $generated_apertium_adj_dict > $dir_resultat/check-apertium-adj.txt
perl $dir_programes/check-nom-apertium.pl $original_apertium_dict $original_apertium_dict $generated_apertium_nom_dict > $dir_resultat/check-apertium-nom.txt

echo "Resultats en: $dir_resultat"