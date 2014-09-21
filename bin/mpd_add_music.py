#!/usr/bin/env python

import argparse
import os
import sys
import re
import subprocess
import codecs
import time

def get_music_dir(mpdconf):
    with open(mpdconf) as mpdconf_io:
        for line in mpdconf_io:
            if line.startswith('music_directory'):
                return re.compile(r'\s+').split(line.rstrip(),1)[1].strip("'\"")

homedir = os.environ['HOME']
configdir = os.environ['XDG_CONFIG_HOME'] or homedir + '/.config'
mpdconf = configdir + '/mpd/mpd.conf'

music_dir = os.path.expanduser(get_music_dir(mpdconf))

parser = argparse.ArgumentParser(description='walks the mpd music dir "%s" and adds music'%music_dir)
parser.add_argument("--regexp", default=r'(.mp3|.ogg)$', help='default "%(default)s"')
parser.add_argument("--mpd-conf", default=mpdconf, help="path to mpd.conf file")
args = parser.parse_args()

args.regexp = re.compile(args.regexp)

# must be in the music_dir and give a path relative to that dir! for it to work

original_dir = os.getcwd()
os.chdir(music_dir)

process = subprocess.Popen(['mpc', 'add'], stdin=subprocess.PIPE)

for root, dirs, files in os.walk('.', followlinks=True):
    filtered = list(filter(lambda file: args.regexp.search(file), files))
    if filtered:
        #filtered = [for fn in filtered]
        formatted = map(lambda mfile: (os.path.join(root, mfile).lstrip('./') + "\n"), filtered)
        process.stdin.write(codecs.encode("".join(formatted), 'utf-8'))

time.sleep(1)
process.terminate()
os.chdir(original_dir)
