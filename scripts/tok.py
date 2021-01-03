#!/usr/bin/env python

from __future__ import absolute_import, division, print_function, unicode_literals

import argparse
import fileinput
import sys
from fairseq import tokenizer

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="input file; use - for stdin")
    args = parser.parse_args()
    # tokenise based on space
    for line in fileinput.input([args.input], openhook=fileinput.hook_compressed):
        line = tokenizer.tokenize_line(line)
        line = " ".join(line)
        sys.stdout.write(line+"\n")

if __name__ == '__main__':
    main()
