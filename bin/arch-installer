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


def run_commands(commands, opts):
    print()
    print("-" * 70)
    print("Going to attempt to run the following:")
    print("-" * 70)
    for command in commands:
        print(command)
    print("-" * 70, " [Now RUNNING]")

    if not opts.dry:
        for command in commands:
            subprocess.run(command, shell=True)


def install_subsection(data, opts):
    special, packages_to_install = partition(lambda item: isinstance(item, dict), data)

    for item in special:
        if pre_commands := item.get("_pre_commands"):
            run_commands(pre_commands, opts)

    base_cmd = ["yay", "-S", "--noconfirm"]
    cmd = base_cmd + packages_to_install
    print("running:", " ".join(cmd))
    if not opts.dry:
        subprocess.run(cmd)
    for item in special:
        if post_commands := item.get("_post_commands"):
            run_commands(post_commands, opts)

        if post_notes := item.get("_post_notes"):
            print()
            print("-" * 70)
            print("Post install notes:")
            print("-" * 70)
            for note in post_notes:
                print(note)


parser = argparse.ArgumentParser()
parser.add_argument("sections", nargs="*", help="install a section")
parser.add_argument(
    "--show",
    action="store_true",
    help="show what will be installed for a key(s) and nothing else",
)
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


def show_section(section_data):
    for thing in section_data:
        if isinstance(thing, dict):
            for key, val in thing.items():
                print(key)
                if isinstance(val, list):
                    for subthing in val:
                        print("  ", subthing)
                else:
                    print(val)
        else:
            print(thing)


if args.list or not args.sections:
    list_sections(doc)

for section in args.sections:
    if section not in doc.keys():
        list_sections(doc)
        raise parser.error("bad section key")

    section_data = doc[section]
    if args.show:
        show_section(section_data)
        continue

    install_subsection(section_data, args)
