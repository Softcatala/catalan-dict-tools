#!/bin/bash
./separa-ordena.sh
./lt-to-fdic.sh
./fdic-to-lt.sh
./compara-tots.sh
emacs ./compara/diff.txt &
