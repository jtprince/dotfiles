#!/usr/bin/env python

import subprocess
from pathlib import Path

this_dir = Path(__file__).resolve().parent

template_file = this_dir / "config.mo"

current_dir = Path.cwd()

yaml_file = list(current_dir.glob("*.yaml"))[0]

cmd = f"mustache {str(yaml_file)} {str(template_file)} > config"
subprocess.run(cmd, shell=True)
