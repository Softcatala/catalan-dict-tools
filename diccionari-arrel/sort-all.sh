#!/bin/bash

for file in *.txt
do
    export LC_ALL=C && sort -u $file -o $file
done
