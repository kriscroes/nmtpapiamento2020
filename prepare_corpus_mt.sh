#!/bin/bash
mkdir -p corpus && cd corpus # create the directory and cd
cp ../formatted_corpus.tsv .
cut -f1 formatted_corpus.tsv > corpus.en-pap.pap
cut -f2 formatted_corpus.tsv > corpus.en-pap.en


if [ -f europarl-v7.pt-en.en ]; then
    echo "data already exists, skipping download."
else
    wget https://www.statmt.org/europarl/v7/pt-en.tgz
    tar -xzvf pt-en.tgz && rm pt-en.tgz
fi
head -n 2700 corpus.en-pap.pap > temp
head -n 2600 temp > train.en-pap.pap
tail -n 100 temp > valid.en-pap.pap
tail -n 300 corpus.en-pap.pap > test.en-pap.pap

head -n 2700 corpus.en-pap.en > temp
head -n 2600 temp > train.en-pap.en
tail -n 100 temp > valid.en-pap.en
tail -n 300 corpus.en-pap.en > test.en-pap.en

paste -d '\t' europarl-v7.pt-en.pt  europarl-v7.pt-en.en > temp
awk '{ print length($0) " " $0; }' temp  | sort -r -n | cut -d ' ' -f 2- > parallel
head -n 1500000 parallel > temp
cat temp | shuf > parallel
cut -f1 parallel > europarl-v7.pt-en.pt
cut -f2 parallel > europarl-v7.pt-en.en

head -n 27000 europarl-v7.pt-en.pt > temp
head -n 26000 temp > train.en-pt.pt
tail -n 1000 temp > valid.en-pt.pt
tail -n 3000 europarl-v7.pt-en.pt > test.en-pt.pt

head -n 27000 europarl-v7.pt-en.en > temp
head -n 26000 temp > train.en-pt.en
tail -n 1000 temp > valid.en-pt.en
tail -n 3000 europarl-v7.pt-en.en > test.en-pt.en

rm temp 
