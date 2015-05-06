#!/usr/bin/env python

import argparse
import fnmatch
import os
import re
import subprocess
import sys
from time import time

def regex(string):
    return re.compile(string)

parser = argparse.ArgumentParser(description="finds all test files and helps run them")
parser.add_argument("-s", "--search", type=regex, help="search against specific test files")
parser.add_argument("-e", "--exclude", type=regex, help="exclude specific test files")
parser.add_argument("-i", "--individually", action='store_true', help="run tests individually")
parser.add_argument("-d", "--dry", action='store_true', help="don't run, just print")
parser.add_argument("--fresh-db", action='store_true', help="don't reuse the DB")
parser.add_argument("--capture", action='store_true', help="don't use --nocapture")
parser.add_argument("-n", "--test-on-network", action='store_true', help="activate tests using network connection")

args = parser.parse_args()

if not os.path.isfile("manage.py"):
    exit("not in django project root!")

print("export REUSE_DB=1   # if you want faster tests")

root = '.'

def run_cmd(cmd, args):
    start = time()
    if not args.dry:
        # this isn't working!!!!
        #if not args.fresh_db:
            #os.environ['REUSE_DB'] = "1"
        subprocess.call(cmd)
        print("[Total Test Time: %f s]\n" % (time() - start))
    else:
        print(" ".join(cmd))

def is_testfile(fname):
    return re.match(r'test.*.py$', fname)

def all_test_files(root):
    matches = []
    for root_, sub_folders, filenames in os.walk(root):
        for filename in filter(is_testfile, filenames):
            matches.append(os.path.join(root_, filename))
    return matches

files = all_test_files(root)

if args.search:
    files = filter(lambda fn: args.search.search(fn), files)

if args.exclude:
    files = filter(lambda fn: not args.exclude.search(fn), files)

if not len(files):
    sys.exit("no files to test!")

cmd = ["./manage.py"]

test_type = "test-on-network" if args.test_on_network else "test"

cmd.append(test_type)

if not args.capture:
    cmd.append("--nocapture")

if args.individually:
    for fn in files:
        run_cmd(cmd + [fn], args)
else:
    start = time()
    run_cmd(cmd + files, args)
