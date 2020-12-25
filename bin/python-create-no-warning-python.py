#!/usr/bin/env python

import argparse
import pathlib
import subprocess

current_python = subprocess.check_output(
    ["pyenv", "which", "python"], text=True
).strip()

NO_WARNING_FILENAME = "python-no-warnings"


parser = argparse.ArgumentParser(
    description=str(
        "creates a python stub for a particular python version"
        "that silences warnings"
    )
)
parser.add_argument(
    "python_path",
    nargs="?",
    default=current_python,
    help=str(
        "the python to create a no warnings python for "
        f"(default {current_python}"
    ),
)
args = parser.parse_args()

new_script = pathlib.Path(args.python_path).parent / NO_WARNING_FILENAME

contents = f"""#!/bin/sh
{args.python_path} -W ignore "$@"
"""

new_script.write_text(contents)
new_script.chmod(0o755)

print(str(new_script))
