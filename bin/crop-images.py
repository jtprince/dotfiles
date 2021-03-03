#!/usr/bin/env python

import argparse
from pathlib import Path

from PIL import Image, ImageOps

parser = argparse.ArgumentParser(description="")
parser.add_argument("images", nargs="+", type=Path, help="paths to image files")
parser.add_argument("-t", "--top", default=0, type=int, help="crop from top")
parser.add_argument(
    "-b", "--bottom", default=0, type=int, help="crop from bottom"
)
parser.add_argument("-l", "--left", default=0, type=int, help="crop from left")
parser.add_argument(
    "-r", "--right", default=0, type=int, help="crop from right"
)
args = parser.parse_args()

border = (args.left, args.top, args.right, args.bottom)

for image_path in args.images:
    image = Image.open(image_path)

    outfile = image_path.with_suffix(".cropped" + image_path.suffix)
    cropped_image = ImageOps.crop(image, border)
    cropped_image.save(str(outfile))
