#!/usr/bin/env python


import argparse
from pathlib import Path
import awswrangler as awr

default_filename = "enveda_search_included_msbs.txt"

parser = argparse.ArgumentParser()
parser.add_argument(
    "outfile", default=Path(default_filename), type=Path, nargs="?", help="outpath file"
)
args = parser.parse_args()


included_msbs = awr.athena.read_sql_table("included_msbs", database="enveda_search")

msrun_ids = included_msbs["msrun_id"].tolist()
args.outfile.write_text("\n".join(msrun_ids) + "\n")
