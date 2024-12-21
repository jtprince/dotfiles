#!/usr/bin/env python

import argparse
from pathlib import Path


import json
import sys


def json_to_netscape(json_file, output_file):
    """
    Convert JSON-formatted cookies to Netscape format.
    """
    try:
        with open(json_file, "r") as f:
            cookies = json.load(f)

        with open(output_file, "w") as f:
            f.write("# Netscape HTTP Cookie File\n")
            for cookie in cookies:
                domain = cookie.get("domain", "")
                http_only = "TRUE" if domain.startswith(".") else "FALSE"
                path = cookie.get("path", "/")
                secure = "TRUE" if cookie.get("secure", False) else "FALSE"
                expiry = cookie.get("expirationDate", "0")
                name = cookie.get("name", "")
                value = cookie.get("value", "")

                f.write(
                    f"{domain}\t{http_only}\t{path}\t{secure}\t{expiry}\t{name}\t{value}\n"
                )

        print(f"Successfully converted cookies to Netscape format: {output_file}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "infile", type=Path, help="infile in json format (EditThisCookie2)"
    )
    args = parser.parse_args()

    json_to_netscape(args.infile, args.infile.with_suffix(".txt"))
