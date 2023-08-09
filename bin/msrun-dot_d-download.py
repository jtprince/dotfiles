#!/usr/bin/env python

import argparse
import subprocess

from misosoup_client import Client

# REWRITE THIS USING BENCHLING!!!

parser = argparse.ArgumentParser()
parser.add_argument("msrun_id", nargs="+", help="the msrun_id")
args = parser.parse_args()

for msrun_id in args.msrun_id:
    databases = Client.get_databases(msrun_id=msrun_id)
    latest_db = databases[-1]
    client = Client(msrun_id, database=latest_db)
    s3_uri = client.get_msrun_uri()

    cmd = ["aws", "s3", "cp", "--recursive", s3_uri, f"./{msrun_id}.d"]
    print(" ".join(cmd))
    subprocess.run(cmd)
