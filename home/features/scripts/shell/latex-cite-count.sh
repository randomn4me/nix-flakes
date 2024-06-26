#!/usr/bin/env python
# author: pkuehn

import argparse
import collections
import os
import re
import sys


def count_aux(files: list):
    citekeys = [citekey
                for file in files
                for line in open(file).read().split('\n') if 'citation' in line
                for citekey in re.findall(r'\{([\w,-]+)\}', line)[0].split(',')]
    return citekeys


def count_bcf(file: str):
    try:
        keys = [key[0]
                for line in open(file).read().split('\n') if 'citekey' in line
                if (key := re.findall(r'>([\w-]+)<', line))]
        return keys
    except Exception as e:
        print(e.with_traceback())


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--bcf', help='read bcf file')
    parser.add_argument('--aux', nargs='+', help='read aux file(s)')

    args = parser.parse_args()

    if args.aux:
        if any(not os.path.isfile(f) for f in args.aux):
            parser.print_help()
            sys.exit()
        citation_keys = count_aux(args.aux)

    elif args.bcf:
        if not os.path.isfile(args.bcf):
            parser.print_help()
            sys.exit()
        citation_keys = count_bcf(args.bcf)

    else:
        parser.print_help()
        sys.exit()

    counter = collections.Counter(citation_keys)
    for key, value in sorted(counter.items(), key=lambda item: item[1]):
        print(f'{key},{value}')
