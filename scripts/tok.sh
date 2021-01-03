#!/bin/bash
if [ $# -ne 1 ]; then
    echo "usage: $0 INFILE"
    exit 1
fi
INFILE=$1
ROOT=$(dirname "$0")
python $ROOT/tok.py $INFILE