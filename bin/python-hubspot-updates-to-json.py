#!/usr/bin/env python2.7
"""usage: {} <file.txt>

example line:
    {'email': u'a@b.com', u'address_2': u'123 way'}

another example line:
    message=503 <blah>; contact_data={u'company': u'acme', 'email': u'a@b.com'}

output: writes a line of json for each to stdout
"""

import sys
import json
import traceback

if len(sys.argv) == 1:
    print(__doc__)
    exit(0)

filename = sys.argv[1]

with open(filename) as infile:
    for line in infile:
        line = line.rstrip()
        try:
            if "contact_data=" in line:
                line = line.split("contact_data=")[-1]
            data = eval(line)
            print(json.dumps(data))
        except:
            sys.stderr.write(line + "\n")
