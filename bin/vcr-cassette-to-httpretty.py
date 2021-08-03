#!/usr/bin/env python

import argparse
import json

import yaml

parser = argparse.ArgumentParser(
    description="converty VCR.py cassettes to httpretty registrations"
)
parser.add_argument("filenames", nargs="+", help="vcr cassette filenames")
parser.add_argument(
    "-d",
    "--include-decorator-line",
    action="store_true",
    help="also include the decorator line",
)
parser.add_argument(
    "-i",
    "--include-import-line",
    action="store_true",
    help="also include the decorator line",
)
args = parser.parse_args()

indent = "    "


template = """
{indent}httpretty.register_uri(
{indent}{indent}httpretty.{method},
{indent}{indent}'{uri}',
{indent}{indent}status={status},
{indent}{indent}body='{body}',
{indent})
"""


for filename in args.filenames:
    with open(filename) as infile:

        print("=" * 60)
        print(filename)
        print("=" * 60)
        data = yaml.load(infile, Loader=yaml.FullLoader)

        if args.include_import_line:
            print("import httpretty")
        if args.include_decorator_line:
            print("    @httpretty.activate")

        for interaction in data["interactions"]:
            request = interaction["request"]
            response = interaction["response"]
            uri = request["uri"]
            method = request["method"]
            status_code = response["status"]["code"]
            body = response["body"]["string"]
            httpretty_output = template.format(
                method=method,
                uri=uri,
                body=body,
                status=status_code,
                indent=indent,
            )

            print(httpretty_output)

            if method != "GET":
                try:
                    request_body = json.loads(request["body"])
                    print(
                        f"{indent}last_request_body = json.loads(httpretty.last_request().body)\n"
                        f"{indent}expected_request_body = {request_body}\n"
                        f"{indent}assert last_request_body == expected_request_body\n"
                    )
                except json.decoder.JSONDecodeError:
                    request_body = request["body"]
                    print(
                        f"{indent}assert httpretty.last_request().body == '{request_body}'"
                    )
