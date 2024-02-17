#!/usr/bin/env python

# compare with roughly same program written in go:
# https://github.com/Code0x58/gitlab-ci-validate/blob/master/gitlab-ci-validate.go
# interpreted vs. binary is not a fair comparison, but this file before comments
# was ~1.4K, while the compiled go program for linux was ~6.8M

try:
    import requests
except:
    print("May need to:\n    pip install --user requests")
    raise

import argparse

DEFAULT_HOST = "https://gitlab.com"
ENDPOINT = "/api/v4/ci/lint"

parser = argparse.ArgumentParser(description="validate .gitlab-ci.yml")
parser.add_argument(
    "gitlab_ci_file", nargs="+", help="one or more `.gitlab-ci.yml` files"
)
parser.add_argument(
    "--host", default=DEFAULT_HOST, help=f"host, defaults to {DEFAULT_HOST}"
)
parser.add_argument(
    "--jsonl", action="store_true", help="one line json output per file"
)
args = parser.parse_args()

url = args.host + ENDPOINT

for filename in args.gitlab_ci_file:
    with open(filename) as infile:
        output = dict(file=filename)
        file_contents = infile.read()
        response = requests.post(url, json=dict(content=file_contents))
        response_data = response.json()
        if response.ok:
            details = dict(output, **response_data)
        else:
            details = dict(
                status="http-error",
                http_data=dict(status_code=response.status_code, data=response_data),
            )

        if args.jsonl:
            print(details)
        else:
            if details.get("status") == "valid":
                print(f"PASS: {details['file']}")
            else:
                print(f"FAIL: {details['file']} {details['errors']}")
