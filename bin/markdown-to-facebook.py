#!/usr/bin/env python

import argparse
import pathlib
import re

link_re = re.compile(r"\[([^\]]+)\]\s?\(([^\)]+)\)")

parser = argparse.ArgumentParser(
    description=str(
        "substitutes links like this '[here](http://ab.com)' "
        "for 'here (http://ab.com)'"
    )
)
parser.add_argument(
    "path", nargs="+", type=pathlib.Path, help="the path to file with markdown"
)
args = parser.parse_args()


for path in args.path:
    outpath = path.with_suffix(".facebook" + path.suffix)
    out = outpath.open("w")

    for line in path.open():
        substituted = link_re.sub(r"\g<1> (\g<2>)", line)
        out.write(substituted)
