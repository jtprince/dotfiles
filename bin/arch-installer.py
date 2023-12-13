#!/usr/bin/env python

import argparse
import os
import subprocess
from pathlib import Path

from ruyaml import YAML

YAML_PATH = Path.home() / "dotfiles/config/arch/installation.yaml"

# Sometimes a python package needs to be installed
os.environ["PIP_REQUIRE_VIRTUALENV"] = "false"


def partition(condition, iterable):
    trues = []
    falses = []
    for item in iterable:
        if condition(item):
            trues.append(item)
        else:
            falses.append(item)
    return trues, falses


def install_subsection(data, opts):
    special, packages_to_install = partition(lambda item: isinstance(item, dict), data)
    base_cmd = ["yay", "-S", "--noconfirm"]
    cmd = base_cmd + packages_to_install
    print("running:", " ".join(cmd))
    if not opts.dry:
        subprocess.run(cmd)
    for item in special:
        if post_commands := item.get("_post_commands"):
            print()
            print("-" * 70)
            print("Now run the following commands:")
            print("-" * 70)
            for command in post_commands:
                print(command)


parser = argparse.ArgumentParser()
parser.add_argument("sections", nargs="*", help="install a section")
parser.add_argument("--list", action="store_true", help="just list sections and exit")
parser.add_argument(
    "--yaml-path", default=YAML_PATH, help="path to the yaml installation file"
)
parser.add_argument("--dry", action="store_true", help="just pretend")

args = parser.parse_args()

yaml = YAML(typ="safe")
doc = yaml.load(args.yaml_path)


def list_sections(doc):
    key_str = "".join(map(lambda key: key + "\n", doc.keys()))
    print(f"AVAILABLE KEYS:\n{key_str}")


if args.list or not args.sections:
    list_sections(doc)

for section in args.sections:
    if section not in doc.keys():
        list_sections(doc)
        raise parser.error("bad section key")
    section_data = doc[section]
    install_subsection(section_data, args)
