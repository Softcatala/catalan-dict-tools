#!/bin/bash
lt_per_a_comparar="/home/jaume/diccionaris/catalan-dict-lt/diccionari.txt"
dir_programes="test-lt-fdic-lt"
dir_intermedi="test-lt-fdic-lt/intermedi"
dir_resultat="resultats/test-lt-fdic-lt"

mkdir $dir_intermedi
echo "Separant i ordenant diccionari LT"
perl $dir_programes/separa-reordena-lt.pl $lt_per_a_comparar $dir_intermedi
for i in $dir_intermedi/ordenats-*.txt
do
    export LC_ALL=C && sort $i -o $i
done

echo "Adjectius: de LT a FDIC"
perl lt-to-fdic/lt-to-fdic.pl adjectius $dir_intermedi
echo "Noms: de LT a FDIC"
perl lt-to-fdic/lt-to-fdic.pl noms $dir_intermedi
echo "Verbs: de LT a FDIC"
mkdir $dir_intermedi/models-verbals
perl lt-to-fdic/extrau-verbs-i-models.pl lt-to-fdic $dir_intermedi


echo "Adjectius: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl $dir_intermedi/noms-fdic.txt $dir_intermedi/noms-lt.txt
echo "Noms: de FDIC a LT..."
perl fdic-to-lt/flexiona.pl $dir_intermedi/adjectius-fdic.txt $dir_intermedi/adjectius-lt.txt
echo "Verbs: de FDIC a LT..."
perl fdic-to-lt/conjuga-verbs.pl $dir_intermedi/verbs-fdic.txt $dir_intermedi/verbs-lt.txt $dir_intermedi/models-verbals/

echo "Comprovat diferències"

echo "*** DIFERÈNCIES ***" > $dir_resultat/diff.txt
for i in noms adjectius verbs
do
    echo "** Compara $i **" >> $dir_resultat/diff.txt
    export LC_ALL=C && sort $dir_intermedi/$i.txt -o $dir_intermedi/$i.txt
    export LC_ALL=C && sort $dir_intermedi/$i-lt.txt -o $dir_intermedi/$i-lt.txt
    diff $dir_intermedi/$i.txt $dir_intermedi/$i-lt.txt >> $dir_resultat/diff.txt
done
rm -rf $dir_intermedi
echo "Fet! Resultats en $dir_resultat"