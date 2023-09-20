#!/usr/bin/env python

import argparse
import json
import os

import requests

parser = argparse.ArgumentParser(description="lists all schemas")
parser.add_argument("--id", nargs="+", help='just show the given ids')
parser.add_argument("--only-ids", action='store_true', help='show the ids and exit')
parser.add_argument("--api-key", help="the geckoboard api-key or path containing it; also checks GECKOBOARD_API")
args = parser.parse_args()

if args.api_key is not None:
    api_key = args.api_key
else:
    api_key = os.environ.get('GECKOBOARD_API')

if not api_key:
    parser.error("Must provide --api-key or via GECKOBOARD_API env var")

url = "https://api.geckoboard.com/datasets/"

auth_params = dict(auth=(api_key, None))
response = requests.get(url, **auth_params)
schemas = response.json()['data']

if args.only_ids:
    for scheme in schemas:
        print(scheme['id'])
    exit(0)

if args.id:
    schemas = [scheme for scheme in schemas if scheme['id'] in args.id]

print(json.dumps(schemas, indent=2))

# in future could optionally transform the results into nice tables
