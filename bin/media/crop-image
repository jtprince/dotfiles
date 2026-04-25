#!/usr/bin/env python

import argparse
from pathlib import Path

from PIL import Image

# assumes images gathered from half screen on chrome browser

LEFT = 45
RIGHT = 52
TOP = 70
BOTTOM = 3


parser = argparse.ArgumentParser(description="")
parser.add_argument("images", nargs="+", type=Path, help="paths to image files")
parser.add_argument("-l", "--left", default=LEFT, type=int, help="crop left")
parser.add_argument("-r", "--right", default=RIGHT, type=int, help="crop right")
parser.add_argument("-t", "--top", default=TOP, type=int, help="crop top")
parser.add_argument("-b", "--bottom", default=BOTTOM, type=int, help="crop bottom")
args = parser.parse_args()

for image_path in args.images:
    image = Image.open(image_path)
    image.crop((args.left, args.top, args.right, args.bottom))
    outfile = image_path.with_suffix(".cropped" + image_path.suffix)
    image.save(outfile)
