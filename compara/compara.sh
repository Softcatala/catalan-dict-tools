#!/bin/bash
export LC_ALL=C && sort $1 > "ordenat-$1"
export LC_ALL=C && sort $2 > "ordenat-$2"
diff "ordenat-$1" "ordenat-$2"
