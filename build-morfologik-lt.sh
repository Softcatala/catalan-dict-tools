#!/bin/bash

cd morfologik-lt

#source dictionary
dict_origen=../resultats/lt/diccionari.txt

#LanguageTool jar
#jarfile=~/github/languagetool/languagetool-tools/target/languagetool-tools-3.5-SNAPSHOT-jar-with-dependencies.jar
jarfile=~/languagetool/languagetool.jar

# replace whitespaces with tabs
perl sptotabs.pl <$dict_origen >diccionari_tabs.txt

# create tagger dictionary with morfologik tools
java -cp $jarfile org.languagetool.tools.POSDictionaryBuilder -i diccionari_tabs.txt -info catalan.info -freq ca_wordlist.xml -o catalan.dict

# dump the tagger dictionary
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i catalan.dict -info catalan.info -o catalan_lt.txt

# create synthesis dictionary with morfologik tools
java -cp $jarfile org.languagetool.tools.SynthDictionaryBuilder -i diccionari_tabs.txt -info catalan_synth.info -o catalan_synth.dict

cp /tmp/SynthDictionaryBuilder*_tags.txt ./catalan_tags.txt
rm /tmp/SynthDictionaryBuilder*_tags.txt

# dump synthesis dictionary
java -cp $jarfile org.languagetool.tools.DictionaryExporter -i catalan_synth.dict -o catalan_synth_lt.txt -info catalan_synth.info

rm diccionari_tabs.txt

#convert catalan_tags.txt to DOS file
sed 's/$'"/`echo \\\r`/" catalan_tags.txt > catalan_tags_dos.txt
rm catalan_tags.txt
mv catalan_tags_dos.txt catalan_tags.txt

target_dir=../resultats/java-lt/src/main/resources/org/languagetool/resource/ca

cp catalan_tags.txt $target_dir
cp catalan.dict $target_dir
cp catalan_synth.dict $target_dir
cp catalan.info $target_dir
cp catalan_synth.info $target_dir
