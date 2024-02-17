#!/usr/bin/env python3

import json
import os
import re
import subprocess
from argparse import ArgumentParser
from collections import defaultdict
from tempfile import NamedTemporaryFile

DOT_EXAMPLE = """
```dot
digraph mygraph {
    nodeA -> nodeB [label="AB edge-label"]
    nodeB -> nodeC [label="BC edge-label"]
    nodeD -> nodeB [label="DB edge-label"]
}
```
"""

JSONTABLE_EXAMPLE = """
```jsontable
[
    { "name": "rinaldo", "color": "blue", "size": 3 },
    { "name": "samantha", "color": "red", "size": 123 }
]
```
"""

NUM_KEY = "num"

RAW_MD_EXT = ".raw.md"
DOT_BLOCK = "dot"
JSONTABLE_BLOCK = "jsontable"

parser = ArgumentParser(
    description=f"converts '{DOT_BLOCK}' and '{JSONTABLE_BLOCK}' codeblocks into ascii graphs and md tables",
    epilog=str(
        "for dot blocks, requires `graph-easy` to be callable; "
        f"if file ends with ext `{RAW_MD_EXT}` then writes to new file `.md`; "
        "if not that extension, outputs to STDOUT"
    ),
)
parser.add_argument("files", nargs="*", help="markdown files with dot or jsontable ")
parser.add_argument(
    "--examples", action="store_true", help="prints out examples and exits"
)
parser.add_argument(
    "--number",
    action="store_true",
    help="add a {NUM_KEY} to each table row if not present",
)
parser.add_argument(
    "--numberkey", default=NUM_KEY, help="the table header for numbered rows"
)


class OptionsMixin:
    def __init__(self, options):
        self.options = options


class ExampleConverterMixin:
    @classmethod
    def convert_example(cls, options):
        lines = [line + "\n" for line in cls.example().splitlines()[1:]]
        return cls(options).convert(lines)


class DotConverter(OptionsMixin, ExampleConverterMixin):
    BLOCK_START = re.compile(r"^```\s*dot$")

    def dot_block_to_ascii_block(self, lines):
        lines.pop(0)
        lines.pop(-1)
        dot_notation = "".join(lines)
        ascii_graph = self.graph_notation_to_ascii(dot_notation)
        encased_in_block = f"```\n{ascii_graph}```\n"
        return encased_in_block

    convert = dot_block_to_ascii_block

    def graph_notation_to_ascii(self, dot_notation):
        tempfile = NamedTemporaryFile(delete=False)
        tempfile.write(dot_notation.encode())
        tempfile.close()
        cmd = ["graph-easy", "--as=ascii", "--from=graphviz", tempfile.name]
        output = subprocess.check_output(cmd).decode()
        os.unlink(tempfile.name)
        return output

    @staticmethod
    def example():
        return DOT_EXAMPLE


class JSONTableConverter(OptionsMixin, ExampleConverterMixin):
    BLOCK_START = re.compile(r"^```\s*jsontable$")

    def jsontable_block_to_md_table(self, lines):
        lines.pop(0)
        lines.pop(-1)
        json_txt = "".join(lines)
        data = json.loads(json_txt)
        return self.convert_json_rows_to_markdown_table(data)

    convert = jsontable_block_to_md_table

    def convert_json_rows_to_markdown_table(self, data_rows):
        """Converts json into markdown.

        Assumes keys are all the same.  Relies on ordering (so, >= python 3.6)

        Example:
        data = [ { "color": "blue", "size", 3}, { "color": "blue", "size", 3} ]
        convert_json_rows_to_markdown_table(data)
        # produces
        | color | size |
        | ----- | ---- |
        | blue  | 3    |
        """
        if self.options.number:
            data_rows = self.add_number(data_rows, self.options.numberkey)

        sizes = defaultdict(int)
        for data_row in data_rows:
            for key, val in data_row.items():
                sizes[key] = max(sizes[key], len(str(val)), len(str(key)))
        size_vals = sizes.values()

        header_cells = data_rows[0].keys()
        divider_cells = ["-" * size for size in sizes.values()]
        other_rows = [data_row.values() for data_row in data_rows]
        all_rows = [header_cells, divider_cells, *other_rows]
        rowified = [self.rowify(row, size_vals) for row in all_rows]
        joined = "\n".join(rowified)
        return joined + "\n"

    def rowify(self, cells, cell_sizes):
        justified = [str(cell).ljust(size) for cell, size in zip(cells, cell_sizes)]
        return "| " + " | ".join(justified) + " |"

    def add_number(self, data_rows, key, start=1):
        if key in data_rows[0]:
            return data_rows
        else:
            return [
                {key: cnt, **data_row} for cnt, data_row in enumerate(data_rows, start)
            ]

    @staticmethod
    def example():
        return JSONTABLE_EXAMPLE


class MarkdownBlockReplacer(OptionsMixin):
    BLOCK_END_RE = re.compile(r"^```$")

    def replace_dot_blocks(self, lines):
        converter = DotConverter(self.options)
        return self._replace_blocks(lines, converter.BLOCK_START, converter.convert)

    def replace_jsontable_blocks(self, lines):
        converter = JSONTableConverter(self.options)
        return self._replace_blocks(lines, converter.BLOCK_START, converter.convert)

    def _replace_blocks(self, lines, start_re, func):
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
                if self.BLOCK_END_RE.match(line):
                    mapped_lines.append(func(to_convert))
                    in_desired_block = False
                continue

            mapped_lines.append(line)

        return mapped_lines


def display_example(example, conversion):
    print("# If your markdown file contains this: ")
    print(example)
    print("# Then it will be replaced with this: ")
    print(conversion)


args = parser.parse_args()
if not (args.examples or args.files):
    parser.error("need markdown files or --examples")


if args.examples:
    display_example(DotConverter.example()[1:-1], DotConverter.convert_example(args))
    display_example(
        JSONTableConverter.example()[1:-1], JSONTableConverter.convert_example(args)
    )
    exit()

for filename in args.files:
    with open(filename) as infile:
        lines = infile.readlines()

    replacer = MarkdownBlockReplacer(args)
    lines = replacer.replace_dot_blocks(lines)
    lines = replacer.replace_jsontable_blocks(lines)

    output = "".join(lines)
    if filename.endswith(RAW_MD_EXT):
        base = os.path.splitext(os.path.splitext(filename)[0])[0]
        outfile = base + ".md"
        with open(outfile, "w") as out:
            print(output, file=out)
    else:
        print(output)
