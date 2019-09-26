#!/usr/bin/env python

# curl -sSL <gist> | python

import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("hostname", help="the hostname to use")
parser.add_argument("--timezone", default="America/Denver", help="an olson db timezone")
parser.add_argument("--lang", default="en_US.UTF-8", help="an olson db timezone")
parser.add_argument("--dry", action='store_true', help="don't run, just print out the command")
args = parser.parse_args()


def run(cmd):
    if args.dry:
        print(cmd)
    else:
        subprocess.run(cmd, shell=True, check=True)


hosts = f"""127.0.0.1\tlocalhost
::1\tlocalhost
127.0.1.1\t{args.hostname}.localdomain\t{args.hostname}"""


cmds = [
    f"ln -sf /usr/share/zoneinfo/{args.timezone} /etc/localtime",
    f"hwclock --systohc",
    f"sed -i '/^#{args.lang}/^#//g' /etc/locale.gen",
    f'echo "LANG={args.lang}" > /etc/locale.conf',
    f'echo -n "{args.hostname}" > /etc/hostname',
    f'echo -n "{hosts}" > /etc/hosts',
    f'passwd',
]

for cmd in cmds:
    run(cmd)
