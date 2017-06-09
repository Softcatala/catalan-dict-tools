#!/bin/bash
dir_programes="fdic-to-apertium"
dir_dades="resultats/lt"
dir_arrel="diccionari-arrel"
dir_resultat="resultats/apertium"


rm -rf $dir_resultat
mkdir $dir_resultat

perl $dir_programes/lt-to-apertium-adj.pl $dir_dades/diccionari.txt $dir_programes/apertium-cat.pardefs > $dir_resultat/adj-languagetool-format-apertium.txt
perl $dir_programes/lt-to-apertium-nom.pl $dir_dades/diccionari.txt $dir_programes/apertium-cat.pardefs > $dir_resultat/nom-languagetool-format-apertium.txt

echo "Resultats en: $dir_resultat"