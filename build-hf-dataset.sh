#!/bin/bash
set -euo pipefail
# Fitxers d'entrada i sortida
fitxer_arrel="./diccionari-arrel/nomspropis-lt.txt"
diccionari_LT="./resultats/lt/diccionari.txt"
diccionari_HF="./resultats/hf-dataset/diccionari.txt"
zip_HF="./resultats/hf-dataset/dataset.zip"
linies_wikidata=$(mktemp)

trap 'rm -f "$linies_wikidata"' EXIT

mkdir -p ./resultats/hf-dataset

# 1) Recollim les línies marcades amb "wikidata" del fitxer arrel,
#    ignorem les línies que comencen per '#' (entrades desactivades)
awk '
    /^[[:space:]]*#/ { next }   # ignorem línies desactivades
    {
        pos = index($0, "#")
        if (pos == 0) next       # sense comentari, no ens interessa
        dades      = substr($0, 1, pos - 1)
        comentari  = substr($0, pos + 1)
        if (comentari ~ /(^|[^[:alnum:]_])wikidata([^[:alnum:]_]|$)/) {
            # Retirem espais sobrants al principi/final de la part de dades,
            # per poder-la comparar amb la línia sencera de diccionari.txt
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", dades)
            if (dades != "") print dades
        }
    }
' "$fitxer_arrel" | sort -u > "$linies_wikidata"
# 2) Filtrem diccionari.txt, eliminem les línies coincidents amb linies_wikidata
#    i retirem el sufix numèric (_1, _2...) del lema (segona columna), si n'hi ha
awk -v fitxer_linies="$linies_wikidata" '
    BEGIN {
        while ((getline linia < fitxer_linies) > 0) {
            marcades[linia] = 1
        }
        close(fitxer_linies)
    }
    {
        if ($0 in marcades) next
        sub(/_[0-9]+$/, "", $2)
        print
    }
' "$diccionari_LT" > "$diccionari_HF"

zip -q -j $zip_HF $diccionari_HF

echo "Fitxer generat: $diccionari_HF" >&2
echo "Arxiu ZIP generat: $zip_HF" >&2
