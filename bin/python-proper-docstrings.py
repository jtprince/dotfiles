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
    NO_DOCSTRINGS = ['__init__', '__repr__', '__str__']

    def __init__(self, path, defline, topline, subline, linenum):
        """ linenum is the defline """
        self.path = path
        self.defline = defline
        self.topline = topline
        self.subline = subline
        self.linenum = linenum

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
        return not any(substr in self.defline for substr in self.NO_DOCSTRINGS)

    def is_missing_docstring(self):
        return (self.topline.count('"""') == 0) and self.docstring_needed()

    def has_docstring(self):
        return self.topline.count('"""') > 0 or self.topline.count("'''") > 0

    def is_singleline(self):
        return self.topline.count('"""') == 2 or self.topline.count("'''") == 2

    def is_testfile(self):
        return re.match(r'test_', os.path.basename(self.path))

    def proper_docstring(self):
        doc = None
        if self.has_docstring():
            if self.is_singleline():
                doc = self.left_padding(self.topline) + '""" ' + self.message_capitalized_and_puncuated() + ' """\n' + self.subline
            elif self.message():  # message on top line need to shift down
                doc = self.left_padding(self.topline) + '"""\n' + self.left_padding(self.topline) + self.message_capitalized_and_puncuated() + "\n" + self.subline
            else:
                doc = self.topline + self.subline
        else:
            if self.is_testfile() and self.docstring_needed():
                if "def setup(" in self.defline:
                    doc = self.left_padding(self.defline) + "    " + '""" Setup. """\n' + self.topline + self.subline
        if doc:
            return doc
        else:
            if self.docstring_needed():
                sys.stderr.write("MISSING DOCSTRING: " + comment.defline.strip() + "\n")
                sys.stderr.write('    File "%s", line %d' % (path, comment.linenum + 1) + "\n")
            return self.topline + self.subline

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


for path in sys.argv[1:]:
    with open(path, 'r') as infile:
        lines = infile.readlines()

    line_num = 0
    comments = []
    for (defline, commentline, subline) in each_cons(lines, 3):
        comment = Comment(path, defline, commentline, subline, line_num)
        if comment.is_bonafide_docstring():
            comments.append(comment)
        line_num += 1

    for comment in comments:
        lines[comment.linenum+1] = comment.proper_docstring_topline()
        lines[comment.linenum+2] = comment.proper_docstring_subline()

    with open(path, 'w') as outfile:
        outfile.write(''.join(lines))
