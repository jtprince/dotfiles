#!/usr/bin/env python

import yaml

import argparse

parser = argparse.ArgumentParser(description="converty VCR.py cassettes to httpretty registrations")
parser.add_argument("filenames", nargs="+", help="vcr cassette filenames")
parser.add_argument("-d", "--include-decorator-line", action='store_true', help="also include the decorator line")
parser.add_argument("-i", "--include-import-line", action='store_true', help="also include the decorator line")
args = parser.parse_args()


template = """
    httpretty.register_uri(
        httpretty.{method},
        '{uri}',
        body='{body}',
    )
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

        for interaction in data['interactions']:
            request = interaction['request']
            response = interaction['response']
            uri = request['uri']
            method = request['method']
            status_code = response['status']['code']
            body = response['body']['string']
            httpretty_output = template.format(method=method, uri=uri, body=body)

            print(httpretty_output)
