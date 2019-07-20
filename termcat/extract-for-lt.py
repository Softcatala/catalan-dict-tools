#!/usr/bin/python3 -S
# -*- coding: utf-8 -*-

import sys, codecs, re, unicodedata
import glob
import xml.etree.ElementTree as ET
from collections import defaultdict


def wordexists(word):
    return word in ltdict

def splitline(line):
    words = line;
    words = re.sub(r"\[.+?\]", r' ', words); #marca d'idioma [fr], etc.
    words = re.sub(r'(.+) -.*', r'\1', words)
    words = re.sub(r"[lds]'", r' ', words);
    words = re.sub(r"-", r' ', words);
    words = re.sub(r"[\(\),\|:\.!\?/]", r' ', words);
    words = re.sub(r"<.+?>", r' ', words);
    words = re.sub(r"\b[0-9\.]+\b", r' ', words);
    words = words.split();
    return words

def wordsthatdontexist(words):
    result = ""
    #print (words)
    for word in splitline(words):
        #print (word)
        if len(word)>2 and word not in ltdict and word.lower() not in ltdict:
            if result:
                result = result + " "
            result = result + word
    return result

#llegir diccionari LT
p = re.compile("(.+) (.+) (.+)")
ltdict = defaultdict()
file = "../resultats/lt/diccionari.txt"
for file in ["../resultats/lt/diccionari.txt", "../resultats/lt/diccionari-dnv.txt"]:
    with open(file) as fp:
        line = fp.readline()
        while line:
            result = p.search(line)
            #print (line + ": 1" + result.group(1) +"; 2 " + result.group(2) +"; 3 " + result.group(3))
            ltdict[result.group(1)] = result.group(2)+" "+result.group(3)
            line = fp.readline()

foutput = codecs.open("output.txt", "w", "utf-8")
files = glob.glob("xml-dicts/*.xml")
for file in files:
    mytree = ET.parse(file)
    dictroot = mytree.getroot()
    #fitxes = dictroot.find('cessiodades').find('fitxes')
    catword = ""
    spaword = ""
    for fitxa in dictroot.iter('fitxa'):
        for denominacio in fitxa.iter('denominacio'):
            if denominacio.attrib.get('llengua') == 'ca':
                catword = denominacio.text
                wordsnotfound = wordsthatdontexist(catword)
                #print (wordsnotfound)
                if wordsnotfound:
                #if catword == catword.lower() and wordsnotfound == catword:
                    foutput.write(catword + ";" + denominacio.attrib.get('categoria') + ";" + wordsnotfound + "\n")
            #if denominacio.attrib.get('llengua') == 'es':
            #    spaword = denominacio.text
        #foutput.write (catword + "\t" + spaword + "\n")
        #spaword = re.sub(r'(.+) -.*', r'\1', spaword)
        #foutput.write (spaword + ",\n")


