#!/usr/bin/env python

import argparse
import re
from collections import Counter
from pathlib import Path


class DuplicateReferences(Exception):
    pass


class MissingReference(Exception):
    pass


CITATION_RE = re.compile(r'\[\^([\w\-_]+)\]')
FOOTNOTE_RE = re.compile(r'^\[\^([\w\-_]+)\]: ', re.MULTILINE)

REDDIT_FORMAT_CITATION = "[{}]"

NEW_EXT = '-reddit.md'

parser = argparse.ArgumentParser()
parser.add_argument("file", help="the markdown file")
parser.add_argument("--new-ext", default=NEW_EXT, help="new extension")
args = parser.parse_args()

# Use dict keys as ordered set
CITATION_ORDER = {}


def replace(match):
    # not sure why we get back a tuple of one?
    citation = match.groups(1)[0]
    CITATION_ORDER[citation] = None
    number_str = str(
        list(CITATION_ORDER.keys()).index(citation) + 1
    )
    return REDDIT_FORMAT_CITATION.format(number_str)


file_base = Path(args.file).resolve().stem
newfile = file_base + args.new_ext


with open(args.file) as infile:
    text = infile.read()

references = FOOTNOTE_RE.findall(text)
duplicates = [item for item, count in Counter(references).items() if count > 1]
if duplicates:
    raise DuplicateReferences(f"Duplicate references: {duplicates}")

new_text = CITATION_RE.sub(replace, text)

missing_references = set(CITATION_ORDER.keys()) - set(references)
if missing_references:
    raise MissingReference(f"Missing one or more references!: {missing_references}")


with open(newfile, 'w') as outfile:
    outfile.write(new_text)
