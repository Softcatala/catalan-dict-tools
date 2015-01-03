#!/bin/bash
perl genera-afixos-hunspell.pl
perl genera-modelsverbals-hunspell.pl
perl fdic-to-hunspell-verbs.pl
perl fdic-to-hunspell-noms-adj.pl
perl fdic-to-hunspell-resta.pl
cat *.dic > resultat/dictionaries/catalan.dic
export LC_ALL=C && sort -u resultat/dictionaries/catalan.dic -o resultat/dictionaries/catalan.dic
cd resultat/dictionaries
cat catalan.dic | wc -l > linies.txt
cat linies.txt catalan.dic > tmp.dic
rm linies.txt
rm catalan.dic
mv tmp.dic catalan.dic
cd ../..
cat header.aff afixos-no-verbs.aff model_cantar_sense_apostrofacio.aff modelsverbals.aff > resultat/dictionaries/catalan.aff
cd resultat
rm ~/Baixades/catalan.oxt
zip -r ~/Baixades/catalan.oxt *
