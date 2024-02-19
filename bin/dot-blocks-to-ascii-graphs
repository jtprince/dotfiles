#!/usr/bin/env python3

import os
import re
import subprocess
from argparse import ArgumentParser
from tempfile import NamedTemporaryFile

DOT_MD_EXT = ".dot.md"

parser = ArgumentParser(
    description="converts 'dot' codeblocks into ascii graphs",
    epilog=str(
        "requires `graph-easy` to be callable; "
        f"if file ends with ext `{DOT_MD_EXT}` then writes to new file `.md`; "
        "if not that extension, outputs to STDOUT"
    ),
)
parser.add_argument(
    "files", nargs="+", help="files with ```dot\\n <graphviz notation>\\n``` in them"
)
args = parser.parse_args()


CODE_BLOCK_START = re.compile(r"^```\s*dot$")
CODE_BLOCK_END = re.compile(r"^```$")


def graph_notation_to_ascii(dot_notation):
    tempfile = NamedTemporaryFile(delete=False)
    tempfile.write(dot_notation.encode())
    tempfile.close()
    cmd = ["graph-easy", "--as=ascii", "--from=graphviz", tempfile.name]
    output = subprocess.check_output(cmd).decode()
    os.unlink(tempfile.name)
    return output


def dot_block_to_ascii(lines):
    lines.pop(0)
    lines.pop(-1)
    dot_notation = "".join(lines)
    ascii_graph = graph_notation_to_ascii(dot_notation)
    encased_in_block = f"```\n{ascii_graph}```\n"
    return encased_in_block


for filename in args.files:
    with open(filename) as infile:
        lines = infile.readlines()

    mapped_lines = []
    to_convert = None
    in_dot_block = False
    for line in lines:
        if CODE_BLOCK_START.match(line):
            to_convert = [line]
            in_dot_block = True
            continue
        if in_dot_block:
            to_convert.append(line)
            if CODE_BLOCK_END.match(line):
                mapped_lines.append(dot_block_to_ascii(to_convert))
                in_dot_block = False
            continue

        mapped_lines.append(line)

    output = "".join(mapped_lines)
    if filename.endswith(DOT_MD_EXT):
        base = os.path.splitext(os.path.splitext(filename)[0])[0]
        outfile = base + ".md"
        with open(outfile, "w") as out:
            print(output, file=out)
    else:
        print(output)
