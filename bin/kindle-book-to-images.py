#!/usr/bin/env python

import argparse
import re
import subprocess
import time

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument(
    "--start", type=int, default=0, help="continue starting at that page"
)
parser.add_argument(
    "--wait", type=int, default=1.25, help="time to wait between screenshot"
)
parser.add_argument("--limit", type=int, default=300, help="this many pages")
args = parser.parse_args()


def run(cmd: str):
    subprocess.run(cmd, shell=True)


def xdo(cmd: str):
    subprocess.run(f"xdotool {cmd}", shell=True)


def get_kindle_window():
    return run('xdotool search "Kindle" | head -1')


response = subprocess.check_output(r"xwininfo", shell=True, text=True)
for line in response.split("\n"):
    if match := re.match(r"xwininfo: Window id: ([^\s]+)", line):
        window_id_hex = match.group(1)
        break

assert window_id_hex

xdo(f"windowfocus {window_id_hex}")
time.sleep(args.wait)

start = args.start
end = args.start + args.limit

for page_number in range(start, end):
    run(f"import -window {window_id_hex} {str(page_number).zfill(4)}.png")
    xdo("key Right")
    time.sleep(args.wait)

print("To continue, run:\n" f"kindle-book-to-images.py --start {end}")
