#!/usr/bin/env python

import argparse
import os
import subprocess
from contextlib import contextmanager
from pathlib import Path

home = Path.home()

SAVE_TO = home / "MEGA/env/passwds_logins/"


@contextmanager
def cd(newdir):
    prevdir = os.getcwd()
    os.chdir(os.path.expanduser(newdir))
    try:
        yield
    finally:
        os.chdir(prevdir)


parser = argparse.ArgumentParser()
parser.add_argument("dirname", help="the path to the directory to be saved")
parser.add_argument("--save-to", help=f"save to path (default: {str(SAVE_TO)})")
args = parser.parse_args()

path = Path(args.dirname)
print(path)
dirname = path.name

zipname = dirname
if zipname.startswith("."):
    zipname = "dot-" + zipname[1:]

secure_name = zipname + ".secure.7z"

parent = path.parent
print(parent)


with cd(parent):

    cmd = ["7z", "a", "-p", secure_name, str(dirname)]
    response = subprocess.run(cmd)
    if not response.returncode == 0:
        raise RuntimeError("Something went wrong with zip creation!  Aborting!")

    rename_to = os.path.join(SAVE_TO, secure_name)
    print("Moving to:", rename_to)
    Path(secure_name).rename(rename_to)
