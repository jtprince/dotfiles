#!/usr/bin/env python3

import json
import os
import re
import subprocess
from argparse import ArgumentParser
from collections import defaultdict
from tempfile import NamedTemporaryFile

RAW_MD_EXT = '.raw.md'

parser = ArgumentParser(
    description="converts 'dot' codeblocks into ascii graphs",
    epilog=str(
        "requires `graph-easy` to be callable; "
        f"if file ends with ext `{RAW_MD_EXT}` then writes to new file `.md`; "
        "if not that extension, outputs to STDOUT"
    )
)
parser.add_argument("files", nargs='+', help="files with ```dot\\n <graphviz notation>\\n``` in them")
args = parser.parse_args()


DOT_BLOCK_START = re.compile(r'^```\s*dot$')
TABLE_BLOCK_START = re.compile(r'^```\s*jsontable$')

BLOCK_END = re.compile(r'^```$')


def graph_notation_to_ascii(dot_notation):
    tempfile = NamedTemporaryFile(delete=False)
    tempfile.write(dot_notation.encode())
    tempfile.close()
    cmd = ['graph-easy', '--as=ascii', "--from=graphviz", tempfile.name]
    output = subprocess.check_output(cmd).decode()
    os.unlink(tempfile.name)
    return output


def rowify(cells, cell_sizes):
    justified = [str(cell).ljust(size) for cell, size in zip(cells, cell_sizes)]
    return "| " + " | ".join(justified) + " |"


def add_number(data_rows, key, start=1):
    if 'num' in data_rows[0]:
        return data_rows
    else:
        return [{key: cnt, **data_row} for cnt, data_row in enumerate(data_rows, start)]


def convert_json_rows_to_markdown_table(data_rows):
    """ Converts json into markdown.

    Assumes keys are all the same.  Relies on ordering (so, >= python 3.6)

    Example:
      data = [ { "color": "blue", "size", 3}, { "color": "blue", "size", 3} ]
      convert_json_rows_to_markdown_table(data)
      # produces
      | color | size |
      | ----- | ---- |
      | blue  | 3    |
    """
    numbered_data_rows = add_number(data_rows, "num")

    sizes = defaultdict(int)
    for data_row in numbered_data_rows:
        for key, val in data_row.items():
            sizes[key] = max(sizes[key], len(str(val)), len(str(key)))
    size_vals = sizes.values()

    header_cells = numbered_data_rows[0].keys()
    divider_cells = ["-" * size for size in sizes.values()]
    other_rows = [data_row.values() for data_row in numbered_data_rows]
    all_rows = [header_cells, divider_cells, *other_rows]
    rowified = [rowify(row, size_vals) for row in all_rows]
    joined = "\n".join(rowified)
    return joined + "\n"


def jsontable_block_to_md_table(lines):
    lines.pop(0)
    lines.pop(-1)
    json_txt = ''.join(lines)
    data = json.loads(json_txt)
    return convert_json_rows_to_markdown_table(data)


def dot_block_to_ascii_block(lines):
    lines.pop(0)
    lines.pop(-1)
    dot_notation = ''.join(lines)
    ascii_graph = graph_notation_to_ascii(dot_notation)
    encased_in_block = f"```\n{ascii_graph}```\n"
    return encased_in_block


def replace_blocks(lines, start_re, end_re, func):
    mapped_lines = []
    to_convert = None
    in_desired_block = False
    for line in lines:
        if start_re.match(line):
            to_convert = [line]
            in_desired_block = True
            continue
        if in_desired_block:
            to_convert.append(line)
            if end_re.match(line):
                mapped_lines.append(func(to_convert))
                in_desired_block = False
            continue

        mapped_lines.append(line)

    return mapped_lines


for filename in args.files:

    with open(filename) as infile:
        lines = infile.readlines()

    lines_table_replaced = replace_blocks(lines, TABLE_BLOCK_START, BLOCK_END, jsontable_block_to_md_table)
    lines_all_replaced = replace_blocks(lines_table_replaced, DOT_BLOCK_START, BLOCK_END, dot_block_to_ascii_block)

    output = ''.join(lines_all_replaced)
    if filename.endswith(RAW_MD_EXT):
        base = os.path.splitext(os.path.splitext(filename)[0])[0]
        outfile = base + ".md"
        with open(outfile, 'w') as out:
            print(output, file=out)
    else:
        print(output)
