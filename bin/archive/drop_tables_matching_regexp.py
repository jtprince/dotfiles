#!/usr/bin/env python

import argparse
import re
import sqlite3
import sys

parser = argparse.ArgumentParser(description='deletes tables matching some regular expression')
parser.add_argument('database', help='the database file')
parser.add_argument('regexp', help='the regexp you are matching')
parser.add_argument('--dry', action='store_true', help='just list the matching tables')
args = parser.parse_args()

conn = sqlite3.connect(args.database)
c = conn.cursor()

c.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;")
reply = c.fetchall()

table_names = map(lambda tup: tup[0], reply)
matching_tables = filter(lambda name: re.search(args.regexp, name), table_names)

if args.dry:
    print("\n".join(matching_tables))
else:
    for name in matching_tables:
        c.execute("DROP TABLE %s" % name)

conn.commit()
conn.close()