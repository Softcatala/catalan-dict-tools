#!/usr/bin/python3 -S
# -*- coding: utf-8 -*-

import sys, codecs, re, unicodedata
from collections import defaultdict


def wordexists(word):
    return word in ltdict

def splitline(line):
    words = line.strip();
    words = words.replace("l·l","lXl")
    words = re.sub(r'^[\-\']+(.+)$', r'\1', words)
    words = re.sub(r'^(.+)[\-\']+$', r'\1', words)
    #words = re.sub(r"\[.+?\]", r' ', words); #marca d'idioma [fr], etc.
    #words = re.sub(r'(.+) -.*', r'\1', words)
    words = re.sub(r"(['’]en|['’]hi|['’]ho|['’]l|['’]ls|['’]m|['’]n|['’]ns|['’]s|['’]t|-el|-els|-em|-en|-ens|-hi|-ho|-l|-la|-les|-li|-lo|-los|-m|-me|-n|-ne|-nos|-s|-se|-t|-te|-us|-vos)+$", r' ', words);
    words = re.sub(r"^[ldstmnLDSTMN][’']", r' ', words);
    words = re.sub(r" [ldstmn][’']", r' ', words);
    words = re.sub(r'^[\-\'’]+(.+)$', r'\1', words)
    words = re.sub(r'^(.+)[\-\'’]+$', r'\1', words)
    #words = re.sub(r"-", r' ', words);
    #words = re.sub(r"[\(\),\|:\.!\?/]", r' ', words);
    #words = re.sub(r"<.+?>", r' ', words);
    #words = re.sub(r"\b[0-9\.]+\b", r' ', words);
    words = words.replace("lXl","l·l")
    words = words.split();
    return words

def wordsthatdontexist(words, freq):
    result = ""
    #print (words)
    if int(freq)<5:
        return words
    for word in splitline(words):
        #print (word)
        if len(word)>1 and word not in ltdict and word.lower() not in ltdict:
            if "-" in word:
                partsOk = True
                parts = word.split("-")
                for part in parts:
                    if part.lower() not in ltdict:
                        partsOk = False
                if partsOk:
                    continue
            if result:
                result = result + " "
            result = result + word
    return result

#llegir diccionari LT
p = re.compile("(.+) (.+) (.+)")
ltdict = defaultdict()
file = "../resultats/lt/diccionari.txt"
for file in ["../resultats/lt/diccionari.txt"]:
    with open(file) as fp:
        line = fp.readline()
        while line:
            result = p.search(line)
            #print (line + ": 1" + result.group(1) +"; 2 " + result.group(2) +"; 3 " + result.group(3))
            if result.group(3) != "Y" and not re.match(r"^[A-Z][A-Z]+$",result.group(1)):   # ^Y => evita abreviacions
                ltdict[result.group(1).lower()] = result.group(2)+" "+result.group(3)
            line = fp.readline()

foutput = codecs.open("output.txt", "w", "utf-8")
filepath = '/home/jortola/wikiextraction/cvtools/word_usage.ca.txt'
#filepath ="./prova.txt"
with open(filepath) as fp:
    line = fp.readline()
    p2 = re.compile("(.+) (.+)")
    while line:
        r2 = p2.search(line)
        w = wordsthatdontexist(r2.group(1), r2.group(2))
        if w:
            foutput.write(r2.group(1).lower()+"\n")
        line = fp.readline()

