#!/usr/bin/env python

import argparse
import os
from csv import DictReader
from pathlib import Path

import requests

CAST = dict(
    datetime=str,
    date=str,
    number=float,
    percentage=float,
    money=float,
    string=str,
)

parser = argparse.ArgumentParser(description="upload csv into dataset; assumes same column names")
parser.add_argument("csvfile", help="csv filename to upload")
parser.add_argument("--name", help="the dataset id; otherwise uses csvfile basename")
parser.add_argument("--api-key", help="the geckoboard api-key or path containing it; also checks GECKOBOARD_API")
parser.add_argument("--append", action='store_true', help="append the data")
args = parser.parse_args()

dataset_id = args.name if args.name else Path(args.csvfile).stem

if args.api_key is not None:
    api_key = args.api_key
else:
    api_key = os.environ.get('GECKOBOARD_API')

if not api_key:
    parser.error("Must provide --api-key or via GECKOBOARD_API env var")

method = 'post' if args.append else 'put'

base_dataset_url = f"https://api.geckoboard.com/datasets/{dataset_id}"


def create_caster(schema):
    caster = {}
    for key, val in schema['fields'].items():
        caster[key] = CAST[val['type']]
    return caster


def cast_(caster, row):
    print("HIYA")
    print(caster)
    print(row)
    return {key: caster[key](val) for key, val in row.items()}


with open(args.csvfile) as infile:
    auth_params = dict(auth=(api_key, None))
    response = requests.get(base_dataset_url, **auth_params)
    schema = response.json()
    caster = create_caster(schema)

    reader = DictReader(infile)
    rows = list(reader)

    print(rows)
    casted_rows = [cast_(caster, row) for row in rows]
    print(casted_rows)

    response = getattr(requests, method)(
        f"{base_dataset_url}/data", json=dict(data=casted_rows), **auth_params
    )

    print(response.json())
