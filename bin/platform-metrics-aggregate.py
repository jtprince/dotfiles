#!/usr/bin/env python

import json
import argparse

# uv pip install "git+https://github.com/enveda/platform-metrics.git@85ac2d3"
from platform_metrics.report.report import aggregated_metrics

TABLES = [
    "feature_count",
    "feature_group_count",
    "peak_intensity_weighted",
    "feature_intensity_weighted",
    "feature_group_intensity_weighted",
    "peak_count",
]


parser = argparse.ArgumentParser()
parser.add_argument("ms_versions", nargs="+", help="the ms_versions")
parser.add_argument("--tables", nargs="*", help="the tables to calculate on")
parser.add_argument("--split", default="test", help="the split")
parser.add_argument("--env", default="dev", help="the environment")
args = parser.parse_args()

if args.tables is None or len(args.tables) == 0:
    args.tables = TABLES


for table in args.tables:
    if table.startswith("feature_group"):
        metric_type = "deadducting"
    elif table.startswith("feature"):
        metric_type = "deisotoping"
    else:
        metric_type = "peak_calling"

    aggregate_params = dict(
        table=table + "_metrics",
        metric_type=metric_type,
        ms_versions=args.ms_versions,
        split=args.split,
        env=args.env,
    )
    df = aggregated_metrics(**aggregate_params)
    print(json.dumps(aggregate_params))
    print(table)
    print(df.to_string(index=False))
    print()
