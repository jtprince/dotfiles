#!/usr/bin/env python

import awswrangler as wr
import pandas as pd
import argparse

# parser = argparse.ArgumentParser()
# parser.add_argument()
# args = parser.parse_args()

pd.set_option("display.max_columns", None)

query = """
"""
# query = """SELECT * FROM benchling.envedatx.entity LIMIT 10"""

df = wr.athena.read_sql_query(query, database="default")
print(df)
