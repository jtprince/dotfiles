#!/usr/bin/env python

import subprocess
import argparse
import os

# will be wayland or x11
session_type = os.envget("XDG_SESSION_TYPE", "x11")


def get_identifers_and_ids(xrandr_output):
    id_to_edid = {}
    lines = xrandr_output.split("\n")

    
    id = None
    for line in lines:
        chars = line.strip()
        if not line[0].isspace():
            id = line.split()[0]
        elif chars == 'EDID:':




if session_type == "x11":
    cmd = [
        "xrandr",
        "--version",
    ]
    output = subprocess.check_output(cmd)
else:
    ...
