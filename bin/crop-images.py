#!/usr/bin/env python

import argparse
from pathlib import Path

# assumes images gathered from half screen on chrome browser

left = 45
right = 52
top = 70
bottom = 3

# WIP

# cmd = f"crop-images.py {{{}}} "-l {left} -r {right} -t {top} -b {bottom}"
#
# parser = argparse.ArgumentParser(description="")
# parser.add_argument("images", nargs="+", type=Path, help="paths to image files")
# args = parser.parse_args()
#
# for image_path in args.images:
#     image = Image.open(image_path)
#
#     outfile = image_path.with_suffix(".cropped" + image_path.suffix)
# subprocess.run(cmd, shell=true)
