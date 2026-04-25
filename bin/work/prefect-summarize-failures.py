#!/usr/bin/env python
"""
There's no easy way from the web UI to export failures. This is a quick hack to enable
copying and pasting of the log into a file and then transforming that into a CSV.
"""

import argparse
from pathlib import Path
import csv


def parse_data(text):
    # Each entry starts with 'feature-calling-paired-msrun-ids'
    entries = text.split("feature-calling-paired-msrun-ids")[
        1:
    ]  # Split and remove first empty entry
    data = []

    for entry in entries:
        lines = entry.strip().split("\n")
        if len(lines) < 14:
            breakpoint()
        record = {
            "job_id": lines[0].strip(),
            "project": lines[1].strip(),
            "component": lines[2].strip(),
            "environment": lines[3].strip(),
            "status": lines[4].strip(),
            "time": lines[5].strip(),
            "duration": lines[6].strip(),
            "result": lines[7].strip(),
            "deployment": lines[9].strip(),
            "work_pool": lines[11].strip(),
            "work_queue": lines[13].strip(),
            "failure_reason": " ".join(
                lines[14:]
            ).strip(),  # Capture multi-line failure reasons
        }
        print("------------ENTRY--------")
        for cnt, (key, val) in enumerate(record.items()):
            print(f"{cnt} {key}: {val}")
        data.append(record)

    return data


def write_csv(data, filename):
    with open(filename, "w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=data[0].keys())
        writer.writeheader()
        for record in data:
            writer.writerow(record)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "log_data_file",
        type=Path,
        help="a file containing a copy/paste of prefect log data",
    )
    args = parser.parse_args()

    csv_output_path = args.log_data_file.with_suffix(".csv")

    text = args.log_data_file.read_text()
    parsed_data = parse_data(text)
    write_csv(parsed_data, filename=str(csv_output_path))
