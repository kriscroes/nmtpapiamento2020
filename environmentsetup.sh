#!/bin/bash
python3 -m venv ../env # create environment
source ../env/bin/activate # activate
pip install --upgrade pip # upgrade pip
pip install fairseq==0.10.1 # install fairseq, pytorch and sacrebleu
pip install sentencepiece==0.1.94 # install sentencepiece for tokenisation
