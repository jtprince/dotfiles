#!/usr/bin/env python

import argparse
import fnmatch
import os
import re
import subprocess
import sys
from time import time

parser = argparse.ArgumentParser(description="runs tests individually")
parser.add_argument("files", default=[], nargs="*", help="test these files")
parser.add_argument("-r", "--root", help="start looking for files")
parser.add_argument("-s", "--start-finding-manage-dot-py", metavar='DIR', default=".", help="where to start looking for the manage.py file--only looks up")
parser.add_argument("-m", "--regex", default=r'.', help="match specific files")
parser.add_argument("--test-filter", default='test_*.py', help="a fnmatch filter")
parser.add_argument("-t", "--test-regex", help="appends 'test_' to front of regex")
parser.add_argument("-d", "--dry", action='store_true', help="don't run the tests")
args = parser.parse_args()

def find_manage_dot_py(start_dir, find='manage.py'):
    """ walk up the dir heirarchy until finding manage.py """
    the_file = os.path.abspath(os.path.join(start_dir, find))
    while not os.path.isfile(the_file):
        find_manage_dot_py(os.path.join(start_dir, '..'))
    return the_file

manage_dot_py = find_manage_dot_py(args.start_finding_manage_dot_py)
if args.test_regex:
    match = re.compile('test_' + args.test_regex)
else:
    match = re.compile(args.regex)

matches = list(args.files)
if not matches:
    root = args.root or '.'
    for root, sub_folders, filenames in os.walk(root):
        for filename in filter(match.search, fnmatch.filter(filenames, args.test_filter)):
            matches.append(os.path.join(root, filename))

if args.dry or (len(sys.argv) == 1):
    print("\n".join(matches))
else:
    for test_file in matches:
        dot_file = test_file[:-3]
        dot_file = re.sub(r'^./', '', dot_file)
        dot_file = re.sub(r'/', '.', dot_file)
        cmd = ["./manage.py", "test", dot_file]
        print(" ".join(cmd))
        start = time()
        subprocess.call(cmd)
        print("[Total Test Time: %f s]\n" % (time() - start))
