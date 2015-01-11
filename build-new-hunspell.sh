#!/bin/bash
dir_programes="fdic-to-hunspell"
dir_dades="$dir_programes/dades"
dir_intermedi="$dir_programes/intermedi"
dir_arrel="diccionari-arrel"
dir_resultat="resultats/hunspell"


for variant in catalan catalan-valencia
do
    echo "*** Generant diccionari: $variant"
    mkdir $dir_intermedi
    echo "Generant fitxers d'afixos"
    perl $dir_programes/genera-afixos-hunspell.pl $dir_dades/regles.hunspell $dir_intermedi/afixos-no-verbs.aff -$variant
    perl $dir_programes/genera-modelsverbals-hunspell.pl $dir_arrel/models-verbals $dir_intermedi/modelsverbals.aff -$variant
    echo "Generant diccionari de verbs"
    perl $dir_programes/fdic-to-hunspell-verbs.pl $dir_arrel/verbs-fdic.txt $dir_intermedi/verbs.dic $dir_arrel/models-verbals -$variant
    echo "Generant diccionari de noms i adjectius"
    perl $dir_programes/fdic-to-hunspell-noms-adj.pl $dir_arrel $dir_intermedi $dir_dades/regles.hunspell -$variant
    echo "Generant diccionari de la resta de categories"
    perl $dir_programes/fdic-to-hunspell-resta.pl $dir_arrel $dir_intermedi/resta.dic -$variant

    cp $dir_dades/*.dic $dir_intermedi
    cp $dir_dades/*.aff $dir_intermedi

    cd $dir_intermedi
    cat *.dic > $variant.dic
    export LC_ALL=C && sort -u $variant.dic -o $variant.dic
    cat $variant.dic | wc -l > linies.txt
    cat linies.txt $variant.dic > tmp.dic
    rm $variant.dic
    mv tmp.dic $variant.dic
    cat header.aff afixos-no-verbs.aff model_cantar_sense_apostrofacio.aff modelsverbals.aff > $variant.aff
    cd -
    rm $dir_resultat/$variant.*
    cp $dir_intermedi/$variant.* $dir_resultat
    rm -rf $dir_intermedi
    echo "Per a fer un test: hunspell -d $variant"
done


echo "FET. Resultats en $dir_resultat"