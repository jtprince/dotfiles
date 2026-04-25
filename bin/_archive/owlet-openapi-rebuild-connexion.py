#!/usr/bin/env python

import argparse
import subprocess
from pathlib import Path

# logic based on:
# https://github.com/OwletCare/skeleton-flask/blob/master/init.sh

# For swagger-cli install instructions: search `npm` here
# https://github.com/OwletCare/common-schemas/#backwards-compatibility-checking

# First, install the generic javascript wrapper:
#     npm install @openapitools/openapi-generator-cli -g

# Then install the specific version of underlying jar you need (which the
# wrapper takes care of).

# Get the version you need:
#     cat .openapi-generator/VERSION

# Then have your wrapper get it:
#     openapi-generator-cli version-manager set <<whatever is your VERSION>>

version = "v0"

parser = argparse.ArgumentParser()
parser.add_argument("service", help="The service name, e.g., 'accounts'")
parser.add_argument("--version", default="v0", help="The version.")
args = parser.parse_args()

bundled_file = f"{args.service}.yaml"

cmd = [
    "swagger-cli",
    "bundle",
    "--dereference",
    "--type",
    "yaml",
    f"common-schemas/openapi/{args.version}/{args.service}.yaml",
    "-o",
    bundled_file,
]

subprocess.run(cmd)

cmd = [
    "openapi-generator-cli",
    "generate",
    "-i",
    bundled_file,
    "-g",
    "python-flask",
    "-o",
    ".",
    "-c",
    "openapi-generator-templates/python-flask-config.yaml",
]

subprocess.run(cmd)

Path(bundled_file).unlink()
