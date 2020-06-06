#!/usr/bin/env bash

VERSION=${1:-dev}
TARGET=${2:-/tmp/xpitest}

ORIGIN=$(pwd)

mkdir -p $TARGET

langs=(ca ca-valencia)
declare -A original
original=([ca]=catalan [ca-valencia]=catalan-valencia)
declare -A code
code=([ca]=ca [ca-valencia]=ca-ES-valencia)

for lang in "${langs[@]}"
do
    cd $ORIGIN/$TARGET
    mkdir $lang
    cd $lang
    cp $ORIGIN/xpi/$lang/manifest.json .
    sed -i -e s/\#VERSION/$VERSION/g manifest.json
    mkdir dictionaries

    cp $ORIGIN/resultats/hunspell/${original[$lang]}.aff dictionaries/${code[$lang]}.aff
    cp $ORIGIN/resultats/hunspell/${original[$lang]}.dic dictionaries/${code[$lang]}.dic

    zip -r $lang.$VERSION.xpi *
    mv $lang.$VERSION.xpi ../
    cd ..
    rm -rf $lang
done
