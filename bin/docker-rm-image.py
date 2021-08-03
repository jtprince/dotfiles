#!/usr/bin/env python

# from argcomplete.completers import ChoicesCompleter
from argparse import ArgumentParser
from subprocess import run

# TODO: interpret image id as an id (can do a simple match to existing ids)
# and accept that also
# TODO: show image ids if there are images with the same name.


def _get_image_names():
    image_lines = run(["docker", "images", "-a"], capture_output=True, encoding="utf-8").stdout.split("\n")
    image_lines.pop(0)
    return [line.split()[0] for line in image_lines if line]


parser = ArgumentParser()
parser.add_argument("name", nargs="*", help="the name of the image")
parser.add_argument("--list", "-l", action="store_true", help="list image names and exit")
parser.add_argument("--force", "-f", action="store_true", help="delete even if with stopped container")


# .completer = ChoicesCompleter(image_names)
args = parser.parse_args()
if args.list or not args.name:
    print("IMAGE NAMES:")
    for name in _get_image_names():
        print("  ", name)




for name in args.name:
    completed = run(["docker", "images", "-q", name], capture_output=True, encoding="utf-8")
    image_id = completed.stdout.split("\n")[0].strip()
    cmd = ["docker", "image", "rm"]
    if args.force:
        cmd.append("--force")
    cmd.append(image_id)
    run(cmd)
