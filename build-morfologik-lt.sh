#!/bin/bash

# Cross-platform sed -i (Mac requires empty string argument, Linux does not)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sedi() { sed -i '' "$@"; }
else
    sedi() { sed -i "$@"; }
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd morfologik-lt

#LanguageTool jar
jarfile=~/target-lt/languagetool.jar
target_dir=../resultats/java-lt/src/main/resources/org/languagetool/resource/ca
rm $target_dir/*

#source dictionaries
cp ../resultats/lt/diccionari.txt /tmp/diccionari.txt
cp ../resultats/lt/diccionari-dnv.txt /tmp/diccionari-dnv.txt

#remove duplicates DNV
python3 ./remove-duplicates-in-dicts.py /tmp/diccionari.txt /tmp/diccionari-dnv.txt

#còpia de dnv, amb tags diferents
cp /tmp/diccionari-dnv.txt /tmp/diccionari-dnv-0.txt
#zero afegit al principi de cada tag
perl -i -p -e 's/^(.+ .+ )(.+)$/${1}0${2}/' /tmp/diccionari-dnv-0.txt

# exclude some words for LT dictionary
sedi -E '/ (aguar|ciar|emblar|binar) /d' /tmp/diccionari.txt


targetdict='ca-ES'

# MULTITOKEN SPELLING
cp multitoken_spelling.masterinfo ${targetdict}_spelling_multitoken.info
cat "$SCRIPT_DIR/diccionari-arrel/noms-propis-multitokens-wikidata.txt" > ${targetdict}_spelling_multitoken.txt

#Removing comments
sedi 's/ *#.*$//' ${targetdict}_spelling_multitoken.txt
sedi -E 's/\s+$//' ${targetdict}_spelling_multitoken.txt
sedi '/^$/d' ${targetdict}_spelling_multitoken.txt

export LC_ALL=C && sort -u ${targetdict}_spelling_multitoken.txt -o ${targetdict}_spelling_multitoken.txt
java -cp $jarfile org.languagetool.tools.SpellDictionaryBuilder -i ${targetdict}_spelling_multitoken.txt -info ${targetdict}_spelling_multitoken.info -o ${targetdict}_spelling_multitoken.dict
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_spelling_multitoken.dict -info ${targetdict}_spelling_multitoken.info -o ${targetdict}_spelling_multitoken_lt.txt

#TAGGER
cp tagger.masterinfo ${targetdict}.info
cat /tmp/diccionari.txt /tmp/diccionari-dnv-0.txt > /tmp/tagger.txt
perl sptotabs.pl </tmp/tagger.txt >/tmp/tagger_tabs.txt
export LC_ALL=C && sort -u /tmp/tagger_tabs.txt -o /tmp/tagger_tabs.txt
java -cp $jarfile org.languagetool.tools.POSDictionaryBuilder -i /tmp/tagger_tabs.txt -info ${targetdict}.info -o ${targetdict}.dict
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}.dict -info ${targetdict}.info -o ${targetdict}_lt.txt


#SYNTHESIZER
cp synth.masterinfo ${targetdict}_synth.info
cat /tmp/diccionari.txt /tmp/diccionari-dnv.txt > /tmp/synth.txt
perl sptotabs.pl </tmp/synth.txt >/tmp/synth_tabs.txt
export LC_ALL=C && sort -u /tmp/synth_tabs.txt -o /tmp/synth_tabs.txt
java -cp $jarfile org.languagetool.tools.SynthDictionaryBuilder -i /tmp/synth_tabs.txt -info ${targetdict}_synth.info -o ${targetdict}_synth.dict
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_synth.dict -o ${targetdict}_synth_lt.txt -info ${targetdict}_synth.info

# SPELLING
cp spelling.masterinfo ${targetdict}_spelling.info
cp /tmp/diccionari.txt /tmp/spelling.txt
perl -i -p -e 's/^(.+) .+ .+$/$1/' /tmp/spelling.txt
cat ../extra-spelling/extra-spelling.txt /tmp/spelling.txt > ${targetdict}_spelling.txt
export LC_ALL=C && sort -u ${targetdict}_spelling.txt -o ${targetdict}_spelling.txt
java -cp $jarfile org.languagetool.tools.SpellDictionaryBuilder -i ${targetdict}_spelling.txt -freq ca_wordlist.xml -info ca-ES_spelling.info -o ${targetdict}_spelling.dict
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_spelling.dict -info ${targetdict}_spelling.info -o ${targetdict}_spelling_lt.txt


   
mv ${targetdict}_synth.dict_tags.txt ${targetdict}_tags.txt  
    

cp ${targetdict}_spelling.dict $target_dir
cp ${targetdict}_spelling.info $target_dir
cp ${targetdict}_tags.txt $target_dir
cp ${targetdict}.dict $target_dir
cp ${targetdict}.info $target_dir
cp ${targetdict}_synth.dict $target_dir
cp ${targetdict}_synth.info $target_dir

cp ${targetdict}_spelling_multitoken.dict $target_dir
cp ${targetdict}_spelling_multitoken.info $target_dir



rm *.info

exit

# extra spelling dict
#java -cp $jarfile org.languagetool.tools.SpellDictionaryBuilder -i ../extra-spelling/extra-spelling.txt -freq ca_wordlist.xml -info ca-ES.info -o ca-extra-spelling.dict
# dump the extra-spelling dict 
#java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ca-extra-spelling.dict -info ca-ES.info -o ca-extra-spelling_lt.txt
#cp ca-extra-spelling.dict $target_dir
#cp ca-ES.info $target_dir/ca-extra-spelling.info
