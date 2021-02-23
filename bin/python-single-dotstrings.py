#!/usr/bin/env python


import argparse
import re
import subprocess

CVIOLET = "\33[35m"
CEND = "\33[0m"


def get_output(cmd):
    print("GETTING OUTPUT:", cmd)
    return subprocess.check_output(cmd, shell=True, text=True).strip()


def run(cmd):
    print("RUNNING:", cmd)
    return subprocess.run(cmd, shell=True, text=True)


parser = argparse.ArgumentParser()
parser.add_argument("start_path", nargs="*", default=".", help="starting path")
parser.add_argument(
    "-l",
    "--files-with-matches",
    action="store_true",
    help="only return the filename",
)
args = parser.parse_args()


paths = " ".join(args.start_path)
response = get_output(rf"rg -A 1 --line-number '\s*def ' {paths}")

parts = response.split("\n--\n")

single_line_docstring_re = re.compile(r'""".*"""')
file_linenum_re = re.compile(r"^([\w/\.][^\:]+)\:(\d+)\:(.*)")


def display(filename, linenum, func, docstring, args):
    if args.files_with_matches:
        print(filename)
    else:
        print()
        print(CVIOLET + f"{filename}:{linenum}" + CEND)
        print(func)
        print(docstring)


is_single_line_docstring = []
for part in parts:
    func_line, docstring_line = part.split("\n")
    if single_line_docstring_re.search(docstring_line):
        filename, linenum_str, func = file_linenum_re.match(func_line).groups()
        func_linenum = int(linenum_str)
        docstring_linenum = func_linenum + 1
        docstring = docstring_line.removeprefix(
            f"{filename}-{docstring_linenum}-"
        )

        display(filename, docstring_linenum, func, docstring, args)
