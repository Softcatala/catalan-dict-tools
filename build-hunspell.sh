#!/bin/bash
dir_programes="fdic-to-hunspell"
dir_dades="$dir_programes/dades"
dir_intermedi="$dir_programes/intermedi"
dir_arrel="diccionari-arrel"
dir_resultat="resultats/hunspell"

cd diccionari-arrel
./sort-all.sh
cd ..

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

    cat $dir_intermedi/*.dic > $dir_intermedi/$variant.dic

    #Fes les exclusions
    echo "Fent exclusions"
    perl $dir_programes/fes-exclusions.pl $dir_dades/exclusions.txt $dir_intermedi/$variant.dic $dir_intermedi/$variant-exclusions.dic

    cd $dir_intermedi
    export LC_ALL=C && sort -u $variant-exclusions.dic -o $variant.dic
    sed '/^$/d' -i $variant.dic
    cat $variant.dic | wc -l > linies.txt
    cat linies.txt $variant.dic > tmp.dic
    rm $variant.dic
    mv tmp.dic $variant.dic
    cat header.aff afixos-no-verbs.aff model_cantar_sense_apostrofacio.aff modelsverbals.aff > $variant.aff
    cd -
    #Converteix a terminacions DOS
    sed -i 's/$/\r/' $dir_intermedi/$variant.dic
    sed -i 's/$/\r/' $dir_intermedi/$variant.aff
    #Mou al directori de resultats
    rm $dir_resultat/$variant.*
    cp $dir_intermedi/$variant.* $dir_resultat
    #Elimina fitxers intermedis
    rm -rf $dir_intermedi
    echo "Per a fer un test: hunspell -d $variant"
done


echo "FET. Resultats en $dir_resultat"