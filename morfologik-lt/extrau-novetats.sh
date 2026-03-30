#!/bin/bash

###
# Extrau les novetats introduïdes en el diccionari LT
# respecte a l'última versió compilada
###

#directori LanguageTool
#lt_tools=~/github/languagetool/languagetool-tools/target/languagetool-tools-3.5-SNAPSHOT-jar-with-dependencies.jar
#lt_tools=~/languagetool/languagetool.jar
lt_tools=~/target-lt/languagetool.jar

# dump the tagger dictionary
cp tagger.masterinfo ca-ES.info
java -cp $lt_tools org.languagetool.tools.DictionaryExporter -i ca-ES.dict -o ca-ES_lt.txt -info ca-ES.info
rm ca-ES.info

cp ca-ES_lt.txt diccionari_antic.txt
echo "Preparant diccionari"
perl -i -pe 's/^(.*)\t(.*)\t(.*)$/$1 $2 $3/' diccionari_antic.txt
perl -i -ne 'print unless /^.* .* 0.*$/' diccionari_antic.txt # esborrem les formes marcades com a valencianes

echo "Ordenant diccionari"
export LC_ALL=C && sort -u diccionari_antic.txt -o diccionari_antic.txt
echo "Comparant diccionaris"
diff ../resultats/lt/diccionari.txt diccionari_antic.txt > diff.txt
cp diff.txt novetats_amb_tag.txt
echo "Extraient novetats"
perl -i -ne 'print unless / aguar /' novetats_amb_tag.txt #excloure aguar
perl -i -ne 'print unless / VMIP1S0S/' novetats_amb_tag.txt #excloure formes del septentrional
perl -i -pe 's/^[^<].*$//' novetats_amb_tag.txt
perl -i -pe 's/^< //' novetats_amb_tag.txt
perl -i -ne 'print unless / (aguar|ciar|emblar|binar) /' novetats_amb_tag.txt #EXCLUSIÓ D'ALGUNS VERBS
perl -i -pe 's/ /\t/g' novetats_amb_tag.txt
perl -i -ne 'print unless /^\s*$/' novetats_amb_tag.txt
cp novetats_amb_tag.txt novetats_sense_tag.txt
perl -i -pe 's/^(.*)\t(.*)\t(.*)$/$1/' novetats_sense_tag.txt
perl -i -ne 'print unless /^\s*$/' novetats_sense_tag.txt
export LC_ALL=C && sort -u novetats_sense_tag.txt -o novetats_sense_tag.txt
cat spelling.head novetats_sense_tag.txt > spelling.txt
cat manual-tagger.head novetats_amb_tag.txt > manual-tagger.txt
cp manual-tagger.txt ~/caresource/added.txt
cp spelling.txt ~/caresource


echo "Extraient paraules esborrades"
grep -E "^> " diff.txt > removed-body.txt
perl -i -pe 's/^> //' removed-body.txt
perl -i -pe 's/ /\t/g' removed-body.txt
perl -i -ne 'print unless /^\s*$/' removed-body.txt
cat removed-tagger.head removed-body.txt > removed.txt
cp removed.txt /home/jaume/github/languagetool/languagetool-language-modules/ca/src/main/resources/org/languagetool/resource/ca/


echo "Resultats en spelling.txt manual-tagger.txt"
# emacs novetats_* &
