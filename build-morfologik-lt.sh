#!/bin/bash

cd morfologik-lt

#LanguageTool jar
jarfile=~/target-lt/languagetool.jar
target_dir=../resultats/java-lt/src/main/resources/org/languagetool/resource/ca
rm $target_dir/*

#source dictionaries
# catalan
cp ../resultats/lt/diccionari.txt /tmp/ca-ES.txt
#sed -i '/ VMIP1S0S/d' /tmp/ca-ES.txt

#catalan including DNV
cat ../resultats/lt/diccionari.txt ../resultats/lt/diccionari-dnv.txt > /tmp/ca-ES-valencia.txt
#sed -i '/ VMIP1S0S/d' /tmp/ca-ES-valencia.txt
sort -u /tmp/ca-ES-valencia.txt -o /tmp/ca-ES-valencia.txt

for targetdict in ca-ES ca-ES-valencia
do
    cp tagger-spelling.masterinfo ${targetdict}.info
    cp tagger-spelling.masterinfo ${targetdict}_spelling.info
    cp synth.masterinfo ${targetdict}_synth.info
    
    # exclude some words for LT dictionary
    sed -i -E '/ (aguar|ciar|emblar|binar) /d' /tmp/${targetdict}.txt

    # replace whitespaces with tabs
    perl sptotabs.pl </tmp/${targetdict}.txt >${targetdict}_tabs.txt
    export LC_ALL=C && sort -u ${targetdict}_tabs.txt -o ${targetdict}_tabs.txt

    # create tagger dictionary with morfologik tools
    java -cp $jarfile org.languagetool.tools.POSDictionaryBuilder -i ${targetdict}_tabs.txt -info ${targetdict}.info -freq ca_wordlist.xml -o ${targetdict}.dict

    # dump the tagger dictionary
    java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}.dict -info ${targetdict}.info -o ${targetdict}_lt.txt

    # create synthesis dictionary with morfologik tools
    java -cp $jarfile org.languagetool.tools.SynthDictionaryBuilder -i ${targetdict}_tabs.txt -info ${targetdict}_synth.info -o ${targetdict}_synth.dict

    #cp /tmp/SynthDictionaryBuilder*_tags.txt ./${targetdict}_tags.txt
    #rm /tmp/SynthDictionaryBuilder*_tags.txt

    # dump synthesis dictionary
    java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_synth.dict -o ${targetdict}_synth_lt.txt -info ${targetdict}_synth.info
    
    # spelling dicts (alternative)
    cp tagger-spelling.masterinfo ${targetdict}_spelling.info
    perl -i -p -e 's/^(.+)\t.+\t.+$/$1/' ${targetdict}_tabs.txt
    cat ../extra-spelling/extra-spelling.txt ${targetdict}_tabs.txt > ${targetdict}_spelling.txt
    export LC_ALL=C && sort -u ${targetdict}_spelling.txt -o ${targetdict}_spelling.txt
    java -cp $jarfile org.languagetool.tools.SpellDictionaryBuilder -i ${targetdict}_spelling.txt -freq ca_wordlist.xml -info ca-ES_spelling.info -o ${targetdict}_spelling.dict
    java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ${targetdict}_spelling.dict -info ${targetdict}_spelling.info -o ${targetdict}_spelling_lt.txt
    
    mv ${targetdict}_synth.dict_tags.txt ${targetdict}_tags.txt

    cp ${targetdict}_spelling.dict $target_dir
    cp ${targetdict}_spelling.info $target_dir/${targetdict}_spelling.info
    cp ${targetdict}_tags.txt $target_dir
    cp ${targetdict}.dict $target_dir
    cp ${targetdict}.info $target_dir
    cp ${targetdict}_synth.dict $target_dir
    cp ${targetdict}_synth.info $target_dir
    
    rm ${targetdict}_tabs.txt
done
rm *.info

exit

# extra spelling dict
#java -cp $jarfile org.languagetool.tools.SpellDictionaryBuilder -i ../extra-spelling/extra-spelling.txt -freq ca_wordlist.xml -info ca-ES.info -o ca-extra-spelling.dict
# dump the extra-spelling dict 
#java -cp $jarfile org.languagetool.tools.DictionaryExporter -i ca-extra-spelling.dict -info ca-ES.info -o ca-extra-spelling_lt.txt
#cp ca-extra-spelling.dict $target_dir
#cp ca-ES.info $target_dir/ca-extra-spelling.info