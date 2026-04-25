#!/usr/bin/env python

import argparse
from pathlib import Path
import pandas as pd


pd.set_option("display.max_columns", None)

parser = argparse.ArgumentParser(
    description="prints headers and first rows of each dataframe"
)
parser.add_argument("parquet_files", type=Path, nargs="+")
parser.add_argument(
    "-n", "--num-rows", type=int, default=5, help="print this number of rows"
)

parser.add_argument(
    "--no-shape", action="store_true", help="don't print shape at the end"
)
parser.add_argument(
    "--no-attrs", action="store_true", help="don't print df.attrs even if they exist"
)

parser.add_argument(
    "-r",
    "--all-rows",
    action="store_true",
    help="display all rows, not just the head",
)

parser.add_argument(
    "-c",
    "--all-cols",
    action="store_true",
    help="don't break columns up with newline",
)


args = parser.parse_args()

if args.all_rows:
    pd.set_option("display.max_rows", None)

if args.all_cols:
    pd.set_option("display.max_columns", None)
    pd.set_option("display.width", None)
    pd.set_option("display.max_colwidth", None)


for path in args.parquet_files:
    print(str(path))
    df = pd.read_parquet(path)

    if df.attrs and not args.no_attrs:
        print("attrs:", df.attrs)

    if args.all_rows:
        print(df)
    else:
        head = df.head(args.num_rows)
        print(head)
    if not args.no_shape:
        print("\nshape:", df.shape)
