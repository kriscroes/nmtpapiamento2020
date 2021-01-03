#!/bin/bash
mkdir -p corpus && cd corpus # create the directory and cd
# Total Corpus is 3000 segment pairs
# We choose 2600 as test and ... as training+validation
# Data is shuffled before selecting training and testing sets
cp ../formatted_corpus.tsv .
cut -f1 formatted_corpus.tsv > corpus.pap
cut -f2 formatted_corpus.tsv > corpus.en
# 
head -n 2700 corpus.pap > temp.pap
head -n 2700 corpus.en > temp.en
head -n 2600 temp.pap > train.pap
head -n 2600 temp.en > train.en
tail -n 100 temp.pap > valid.pap
tail -n 100 temp.en > valid.en
tail -n 300 corpus.en > test.en
tail -n 300 corpus.pap > test.pap
rm temp.pap temp.en formatted_corpus.tsv 
