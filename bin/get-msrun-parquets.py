#!/usr/bin/env python

import argparse
from pathlib import Path
from typing import List, Optional

from misosoup_client import Client

parser = argparse.ArgumentParser()
parser.add_argument("msrun_ids", nargs="+")
parser.add_argument("--msdb", default="ms", help="the msdb")
parser.add_argument("--tables", nargs="+", help="tables, defaults to all core tables")
parser.add_argument("--outdir", type=Path, help="dump in this path")
args = parser.parse_args()


BUCKET = "enveda-data-misosoup"
PARQUET_EXT = ".parquet"
if args.tables:
    tables = args.tables
else:
    tables = Client.CORE_TABLES


def retrieve_dataframes(
    msrun_id: str, msdb: str, tables: List[str], outdir: Optional[Path]
):
    outdir = Path(msrun_id) if outdir is None else outdir
    print("OUTDIR:", str(outdir))
    outdir.mkdir(exist_ok=True, parents=True)

    client = Client([msrun_id], msdb=msdb)
    for table in tables:
        if "4" in msdb and table == "feature_group":
            print(
                "ms 4 series with feature group, using custom query to pass client bug"
            )
            df = client.query(
                "select * from feature_group where msrun_id = 'msrun_id'", database=msdb
            )
            df["feature_group_id"] = df["id"]
        else:
            df = client.get_table(table)

        df.to_parquet(outdir / f"{table}{PARQUET_EXT}")


for msrun_id in args.msrun_ids:
    retrieve_dataframes(
        msrun_id=msrun_id, msdb=args.msdb, tables=tables, outdir=args.outdir
    )
