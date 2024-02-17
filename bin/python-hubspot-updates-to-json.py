#!/usr/bin/env python3
"""usage: {} <file.txt>

example line:
    {'email': u'a@b.com', u'address_2': u'123 way'}

other lines that will work (contact_data and update_request):
    message=503 <blah>; contact_data={'company': 'acme', 'email': 'a@b.com'}
    message=(2006 <blah>); update_request={'options': <whatever> }

output: writes a line of json for each to stdout
"""
LEADERS = ("contact_data=", "update_request=")

import json
import sys

if len(sys.argv) == 1:
    print(__doc__)
    exit(0)

filename = sys.argv[1]

with open(filename) as infile:
    for line in infile:
        line = line.rstrip()
        try:
            for leader in LEADERS:
                if leader in line:
                    line = line.split(leader)[-1]
            data = eval(line)
            print(json.dumps(data))
        except:
            sys.stderr.write(line + "\n")
