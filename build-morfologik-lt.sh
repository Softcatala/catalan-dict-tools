#!/bin/bash

cd morfologik-lt


#LanguageTool jar
#jarfile=~/github/languagetool/languagetool-tools/target/languagetool-tools-3.5-SNAPSHOT-jar-with-dependencies.jar
jarfile=~/target-lt/languagetool.jar

target_dir=../resultats/java-lt/src/main/resources/org/languagetool/resource/ca

#source dictionaries
# catalan
cp ../resultats/lt/diccionari.txt /tmp/ca-ES.txt
#catalan including DNV
cat ../resultats/lt/diccionari.txt ../resultats/lt/diccionari-dnv.txt > /tmp/ca-ES-valencia.txt
sort -u /tmp/ca-ES-valencia.txt -o /tmp/ca-ES-valencia.txt

for targetdict in ca-ES ca-ES-valencia
do
    # exclude some words for LT dictionary
    sed -i "/ aguar /d" ${targetdict}.txt

    # replace whitespaces with tabs
    perl sptotabs.pl </tmp/${targetdict}.txt >${targetdict}_tabs.txt

    # create tagger dictionary with morfologik tools
    java -cp $jarfile org.languagetool.tools.POSDictionaryBuilder -i ${targetdict}_tabs.txt -info ${targetdict}.info -freq ca_wordlist.xml -o ${targetdict}.dict

    # dump the tagger dictionary
    java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}.dict -info ${targetdict}.info -o ${targetdict}_lt.txt

    # create synthesis dictionary with morfologik tools
    java -cp $jarfile org.languagetool.tools.SynthDictionaryBuilder -i ${targetdict}_tabs.txt -info ${targetdict}_synth.info -o ${targetdict}_synth.dict

    cp /tmp/SynthDictionaryBuilder*_tags.txt ./${targetdict}_tags.txt
    rm /tmp/SynthDictionaryBuilder*_tags.txt

    # dump synthesis dictionary
    java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_synth.dict -o ${targetdict}_synth_lt.txt -info ${targetdict}_synth.info

    rm ${targetdict}_tabs.txt

    #convert catalan_tags.txt to DOS file
    sed 's/$'"/`echo \\\r`/" ${targetdict}_tags.txt > ${targetdict}_tags_dos.txt
    rm ${targetdict}_tags.txt
    mv ${targetdict}_tags_dos.txt ${targetdict}_tags.txt

    cp ${targetdict}_tags.txt $target_dir
    cp ${targetdict}.dict $target_dir
    cp ${targetdict}_synth.dict $target_dir
    cp ${targetdict}.info $target_dir
    cp ${targetdict}_synth.info $target_dir
done