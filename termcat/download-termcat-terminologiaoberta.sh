#!/bin/bash
cd download
rm -rf *
for i in {0..13..1}
do
    wget "https://www.termcat.cat/ca/terminologia-oberta?page=${i}" -O "termcat-${i}.html"
done
grep "href=\"https://www.termcat.cat/Thor/.*xml" *.html > xml-dicts.txt
perl -pi -e 's/.*href="(https:\/\/www.termcat.cat\/Thor\/.*xml)" .*/\1/' xml-dicts.txt
wget -i xml-dicts.txt
rm *.html
cd ..
