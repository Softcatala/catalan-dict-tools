#!/bin/bash
dir_programes="fdic-to-apertium"
original_apertium_dict="/home/jaume/apertium/apertium-cat/apertium-cat.cat.dix"
generated_apertium_dict="resultats/apertium/adj-languagetool-format-apertium.txt"
dir_resultat="tests-apertium"

rm -rf $dir_resultat
mkdir $dir_resultat

perl $dir_programes/check-adj-apertium.pl $dir_programes/apertium-cat.pardefs $original_apertium_dict $generated_apertium_dict > $dir_resultat/check-apertium-adj.txt

echo "Resultats en: $dir_resultat"