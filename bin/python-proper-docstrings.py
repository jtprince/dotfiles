#!/usr/bin/env python

import argparse
import os
import re
import sys
from itertools import islice
from itertools import takewhile
from itertools import tee

try:
    from itertools import izip  # python 2
except ImportError:
    from builtins import zip as izip  # python 3


def each_cons(sequence, n):
    return izip(
        *(
            islice(g, i, None)
            for i, g in
            enumerate(tee(sequence, n))
        )
    )


class Comment(object):
    NO_DOCSTRINGS = ['__init__', '__repr__', '__str__', '__enter__', '__exit__']

    def __init__(self, path, defline, topline, subline, linenum):
        """ linenum is the defline """
        self.path = path
        self.defline = defline
        self.topline = topline
        self.subline = subline
        self.linenum = linenum
        self.docstring_added = False
        self.already_made_docstring = False

    def message(self):
        return self.topline.strip().strip(' "')

    def message_capitalized(self):
        return self.message().capitalize()

    def message_capitalized_and_puncuated(self):
        str_ = self.message_capitalized()
        if str_[-1] != '.':
            str_ += '.'
        return str_

    def docstring_needed(self):
        return not self.has_docstring() and not any(substr in self.defline for substr in self.NO_DOCSTRINGS) and not self.docstring_added

    def is_missing_docstring(self):
        return (self.topline.count('"""') == 0) and self.docstring_needed()

    def has_docstring(self):
        return self.topline.count('"""') > 0 or self.topline.count("'''") > 0

    def is_singleline(self):
        return self.topline.count('"""') == 2 or self.topline.count("'''") == 2

    def is_testfile(self):
        return re.match(r'test_', os.path.basename(self.path))

    def proper_docstring(self):
        if self.already_made_docstring:
            return self.already_made_docstring
        else:
            self.already_made_docstring = True
            docstr = None
            if self.has_docstring():
                if self.is_singleline():
                    docstr = self.left_padding(self.topline) + '""" ' + self.message_capitalized_and_puncuated() + ' """\n' + self.subline
                elif self.message():  # message on top line need to shift down
                    docstr = self.left_padding(self.topline) + '"""\n' + self.left_padding(self.topline) + self.message_capitalized_and_puncuated() + "\n" + self.subline
                else:
                    docstr = self.topline + self.subline
            else:
                if self.is_testfile() and self.docstring_needed():
                    if "def setup(" in self.defline or "def setUp(" in self.defline:
                        print("HIYA")
                        print(self.topline)
                        print(self.subline)
                        docstr = self.left_padding(self.defline) + "    " + '""" Setup. """\n' + self.topline + self.subline
                        self.docstring_added = True
            if not docstr:
                docstr = self.topline + self.subline

            self.already_made_docstring = docstr
            return docstr


    def proper_docstring_lines(self):
        (first, second) = self.proper_docstring().split("\n", 1)
        return [first + "\n", second]

    def proper_docstring_topline(self):
        return self.proper_docstring_lines()[0]

    def proper_docstring_subline(self):
        return self.proper_docstring_lines()[1]

    def left_padding(self, line):
        return "".join(takewhile(lambda c: c == ' ',  line))

    def is_bonafide_docstring(self):
        return any(keyword in self.defline for keyword in ['def ', 'class ']) and ('(' in self.defline)

parser = argparse.ArgumentParser()
parser.add_argument("paths", nargs="+", help="file to fix")
parser.add_argument("--open", action='store_true', help="open in gvim the files missing doc strings")
args = parser.parse_args()


paths_with_missing_docstrings = []
for path in args.paths:
    with open(path, 'r') as infile:
        lines = infile.readlines()

    comments = []
    line_num = 0
    for (defline, commentline, subline) in each_cons(lines, 3):
        comment = Comment(path, defline, commentline, subline, line_num)
        if comment.is_bonafide_docstring():
            comments.append(comment)
        line_num += 1

    for comment in comments:
        lines[comment.linenum+1] = comment.proper_docstring_topline()
        lines[comment.linenum+2] = comment.proper_docstring_subline()

        if comment.docstring_needed():
            sys.stderr.write("MISSING DOCSTRING: " + comment.defline.strip() + "\n")
            sys.stderr.write('    File "%s", line %d' % (path, comment.linenum + 1) + "\n")

    if any(comment for comment in comments if comment.docstring_needed()):
        paths_with_missing_docstrings.append(path)

    with open(path, 'w') as outfile:
        outfile.write(''.join(lines))

if args.open:
    cmd = "gvim " + " ".join(paths_with_missing_docstrings)
    os.system(cmd)
