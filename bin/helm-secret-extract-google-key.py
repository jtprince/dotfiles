#!/usr/bin/env python

import argparse
import base64
import subprocess
import sys
from pathlib import Path

# pip install pyyaml
import yaml

parser = argparse.ArgumentParser(
    description="Extracts google creds from a helm secret.*.yaml file"
)
parser.add_argument("secret_file", type=Path, help="a secrets.*.yaml file")
parser.add_argument(
    "-o",
    "--outfile",
    type=Path,
    help=str("defaults to stdout " "(safe to capture stdout with redirects instead)"),
)
parser.add_argument(
    "--no-cleanup", action="store_true", help="don't remove decrypted file"
)
args = parser.parse_args()

# helm-decrypt:
#    https://github.com/jtprince/dotfiles/blob/master/bin/helm-decrypt
base = ["helm-decrypt", "--force"]
cmd = base + [str(args.secret_file)]

subprocess.check_call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

decrypted = args.secret_file.with_suffix(args.secret_file.suffix + ".dec")
if not decrypted.exists():
    raise RuntimeError(f"Failed to create decrypted file {str(decrypted)}")

data = yaml.safe_load(decrypted.open())

if not args.no_cleanup:
    print(f"clean up removing file: {str(decrypted)}", file=sys.stderr)
    decrypted.unlink()

base64_encoded = data["secrets"]["googleKey"]
google_json = base64.b64decode(base64_encoded).decode("utf-8")

out = args.outfile.open("w") if args.outfile else sys.stdout


out.write(google_json)
