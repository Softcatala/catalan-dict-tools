#!/bin/bash
perl genera-afixos-hunspell.pl
perl genera-modelsverbals-hunspell.pl
perl fdic-to-hunspell-verbs.pl
perl fdic-to-hunspell-noms-adj.pl
perl fdic-to-hunspell-resta.pl
cat *.dic > resultat/dictionaries/catalan.dic
export LC_ALL=C && sort -u resultat/dictionaries/catalan.dic -o resultat/dictionaries/catalan.dic
cat header.aff afixos-no-verbs.aff modelsverbals.aff > resultat/dictionaries/catalan.aff
cd resultat
rm ~/Baixades/catalan.oxt
zip -r ~/Baixades/catalan.oxt *
