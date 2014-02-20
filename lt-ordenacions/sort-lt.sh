#!/bin/bash
cd ../lt-separat-reordenat
for i in *.txt
do
    export LC_ALL=C && sort $i > "../lt-ordenacions/ordenats-$i"
done

