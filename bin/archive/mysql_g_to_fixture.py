#!/usr/bin/env python

import argparse
import json
import sys

parser = argparse.ArgumentParser(
    description="paste the output of a query with \\G on the end and this will transform into the fields for a initial fixture"
)
parser.add_argument(
    "infile",
    nargs="?",
    type=argparse.FileType("r"),
    default=sys.stdin,
    help="name of the file with mysql data, informally called <file>.sqlg",
)

args = parser.parse_args()


def display(fields):
    json_output = json.dumps(fields)
    print(json_output)


current = None
for line in args.infile:
    if line[0] == "*":
        if current:
            display(current)
        current = {}
        continue
    stripped = line.strip()
    if stripped and stripped[0] != "*":
        parts = stripped.split(": ", 1)
        key, value = parts[0], parts[1] if len(parts) == 2 else None
        if key[-1] == ":":
            key = key[0:-1]
        current[key] = value

display(current)
