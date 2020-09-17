#!/usr/bin/env python

import argparse
import subprocess
from pathlib import Path


CONF_FMT_STRING = """
{{
    "python.linting.pylintEnabled": true,
    "python.linting.flake8Enabled": false,
    "python.linting.enabled": true,
    "python.pythonPath": "{}"
}}
"""

PROJECT_ROOT_CONFIG = ".vim"
SETTINGS_FILE = "coc-settings.json"

if not Path(".git").exists():
    raise RuntimeError("Must be in a project root.")

python_path = subprocess.getoutput("pyenv which python")

if not python_path:
    raise RuntimeError("Could not determine python path!")

config_root = Path(PROJECT_ROOT_CONFIG)
config_root.mkdir(exist_ok=True)
settings_file = config_root / Path(SETTINGS_FILE)

config = CONF_FMT_STRING.format(python_path)

settings_file.write_text(config)
print(f"Writing to {settings_file} with python interpreter: ")
print(python_path)
