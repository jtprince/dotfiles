#!/usr/bin/env python

import argparse
import itertools
import json
import random
import time
from pathlib import Path

import requests

parser = argparse.ArgumentParser()
parser.add_argument("usernames", nargs="+", help="the username")
args = parser.parse_args()

headers = {"User-agent": "jtprince_special_sauce 1.23.4"}


def make_filename(num):
    return str(num).zfill(5) + ".pp.json"


def make_placeholder_params(after=None):
    return {} if after is None else dict(count=25, after=after)


for username in args.usernames:
    url = f"https://www.reddit.com/user/{username}.json"
    after = None
    for index in itertools.count(start=1):
        params = make_placeholder_params(after)
        print("params:", params)
        response = requests.get(url, params=params, headers=headers)
        if response.ok:
            data = response.json()
            after = data["data"]["after"]
            if after is None:
                break
            filename = make_filename(index)
            print("Writing to:", filename)
            Path(filename).write_text(json.dumps(data, indent=2))
            sleep_seconds = random.randint(1, 10)
            print("sleeping for:", sleep_seconds)
            time.sleep(sleep_seconds)
        else:
            print("FAILED CALL!")
            print(response.status_code)
            print(response.text)
            print("index:", index)
            print("after:", after)
            breakpoint()
            print("here")
