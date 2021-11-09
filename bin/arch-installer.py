#!/usr/bin/env python

import argparse

parser = argparse.ArgumentParser()
parser.add_argument(
    "--video",
    choices=["intel", "amd", "nvidia"],
    required=True,
    help="which video card",
)
parser.add_argument(
    "--hostname",
    required=True,
    help="name of the host",
)

args = parser.parse_args()
