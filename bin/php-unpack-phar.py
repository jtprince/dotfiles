#!/usr/bin/env python

import argparse
import subprocess
import os

parser = argparse.ArgumentParser()
parser.add_argument("infile", help="the path to the file")

args = parser.parse_args()

args.infile

_dir = os.path.splitext(args.infile)[0]

cmd = "php -r 'new Phar(\"{}\");".format(args.infile)
_cmd = cmd + "$phar->extractTo(\"{}\");".format(args.infile))

print(cmd)
#subprocess.call(cmd, shell=True)
