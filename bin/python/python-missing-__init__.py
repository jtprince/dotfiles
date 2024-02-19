#!/usr/bin/env python

import argparse
import os
from pathlib import Path

parser = argparse.ArgumentParser(description="find all missing __init__.py files")
parser.add_argument("start_dir", help="the root dir for traversing down")
parser.add_argument("--create", action="store_true", help="create missing files.")
args = parser.parse_args()

for dir_name, subdirs, file_list in os.walk(args.start_dir):
    if "__pycache__" in dir_name:
        continue
    if "__init__.py" not in file_list:
        print(dir_name)
        if args.create:
            path = Path(dir_name) / "__init__.py"
            path.touch(exist_ok=True)
            print(f"created {str(path)}")
