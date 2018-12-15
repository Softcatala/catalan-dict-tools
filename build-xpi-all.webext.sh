#!/usr/bin/env bash

VERSION=$1
TARGET=$2

ORIGIN=$(pwd)

langs=(ca ca-valencia)
declare -A original
original=([ca]=catalan [ca-valencia]=catalan-valencia)
declare -A code
code=([ca]=ca [ca-valencia]=ca-ES-valencia)

for lang in "${langs[@]}"
do
    cd $TARGET
    mkdir $lang
    cd $lang
    cp $ORIGIN/xpi/$lang/manifest.json .
    sed -i -e s/\#VERSION/$VERSION/g manifest.json
    mkdir dictionaries

    cp $ORIGIN/resultats/hunspell/${original[$lang]}.aff dictionaries/${code[$lang]}.aff
    cp $ORIGIN/resultats/hunspell/${original[$lang]}.dic dictionaries/${code[$lang]}.dic

    zip -r $lang.xpi *
    mv $lang.xpi ../
done
