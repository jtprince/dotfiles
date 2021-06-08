#!/usr/bin/env python

# ruby-mustache provides `mustache`
# yay -S ruby-mustache

from functools import partial
from pathlib import Path
from subprocess import run

this_dir = Path(__file__).resolve().parent

template_file = this_dir / "config.mo"
preamble = this_dir / "preamble.txt"

current_dir = Path.cwd()

yaml_file = list(current_dir.glob("*.yaml"))[0]

cmd = f"mustache {str(yaml_file)} {str(template_file)} > _config_no_preamble"

runshell = partial(run, shell=True)

runshell(cmd)

cmd = f"cat {str(preamble)} _config_no_preamble > config"
runshell(cmd)

runshell("rm _config_no_preamble")
