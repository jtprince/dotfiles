#!/usr/bin/env python

import argparse
import os

parser = argparse.ArgumentParser(description="find all missing __init__.py files")
parser.add_argument("start_dir", help="the root dir for traversing down")
args = parser.parse_args()

for dir_name, subdirs, file_list in os.walk(args.start_dir):
    if '__init__.py' not in file_list:
        print(dir_name)