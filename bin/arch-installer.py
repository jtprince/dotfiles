#!/usr/bin/env python

import argparse
import subprocess
from pathlib import Path

from ruamel.yaml import YAML

YAML_PATH = Path.home() / "dotfiles/config/arch/installation.yaml"


def partition(condition, iterable):
    trues = []
    falses = []
    for item in iterable:
        if condition(item):
            trues.append(item)
        else:
            falses.append(item)
    return trues, falses


def install_subsection(data):
    special, packages = partition(lambda item: isinstance(item, dict), data)
    cmd = ["yay", "-S", "--noconfirm"]
    subprocess.run(cmd + packages)


parser = argparse.ArgumentParser()
parser.add_argument(
    "--video",
    choices=["intel", "amd", "nvidia"],
    help="which video card",
)
parser.add_argument(
    "--hostname",
    help="name of the host",
)
parser.add_argument(
    "--yaml-path", default=YAML_PATH, help="path to the yaml installation file"
)
parser.add_argument(
    "--install-subsections", help="section.subsection[,subsection]"
)

args = parser.parse_args()

yaml = YAML(typ="safe")
doc = yaml.load(args.yaml_path)

if args.install_subsections:
    if "." in args.install_subsections:
        section, subsections_str = args.install_subsections.split(".", 1)
        subsections = subsections_str.split(",")
        section_data = doc[section]
        for subsection in subsections:
            subsection_data = section_data[subsection]
            install_subsection(subsection_data)
