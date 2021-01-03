#!/usr/bin/env python

from __future__ import absolute_import, division, print_function, unicode_literals

import argparse
import fileinput
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="input file; use - for stdin")
    args = parser.parse_args()
    # tokenise based on space
    for line in fileinput.input([args.input], openhook=fileinput.hook_compressed):
        line = line.decode("utf-8")
        line = line.split("\t")
        src, tgt = line[0].strip(), line[1].strip()
        output = src+'.\t'+tgt+'.\n'
        sys.stdout.write(output.encode("utf-8"))

if __name__ == '__main__':
    main()