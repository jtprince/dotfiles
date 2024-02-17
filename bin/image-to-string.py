#!/usr/bin/env python3

import argparse

import pytesseract
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("filename", help="the name of the image file")

args = parser.parse_args()
img = Image.open(args.filename)
string = pytesseract.image_to_string(
    img,
    lang="eng",
    # config='--psm 10 --oem 3 -c tessedit_char_whitelist=0123456789'
    # config='--psm 10 --oem 3'
)

print(string)
