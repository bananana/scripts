#!/usr/bin/env python3

import argparse
import time
import itertools
import random


parser = argparse.ArgumentParser(description='Useless')
parser.add_argument('filename', nargs='?')
parser.add_argument('-l',
                    '--loop',
                    action='store_true',
                    help='never stop')
args = parser.parse_args()


def be_useless(filename):
    with open(filename, 'r') as f:
        for c in itertools.chain.from_iterable(f):
            wait_time = float(format(random.uniform(0.05, 0.20), '.2f'))
            time.sleep(wait_time)
            print(c, end='', flush=True)


if args.filename and not args.loop:
    try:
        be_useless(args.filename)
    except FileNotFoundError:
        print('%s: No such file or directory' % args.filename)

elif args.loop and args.filename:
    try:
        while True:
            be_useless(args.filename)
    except KeyboardInterrupt:
        print('\nBye!')

else:
    parser.print_help()
