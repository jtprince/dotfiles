#!/usr/bin/env python

import subprocess
from pathlib import Path


CONF_FMT_STRING = """
{{
    "python.linting.pylintEnabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.enabled": true,
    "python.jediEnabled": false,
    "python.pythonPath": "{python_path}",
    "python.autoComplete.extraPaths": ["{python_extra_path}"]
}}
""".lstrip()

PROJECT_ROOT_CONFIG = ".vim"
SETTINGS_FILE = "coc-settings.json"

if not Path(".git").exists():
    raise RuntimeError("Must be in a project root.")

python_path = Path(subprocess.getoutput("pyenv which python"))
python_version = subprocess.getoutput("python --version").split()[-1]

# e.g., 3.8.5 -> 3.8
python_minor_version = ".".join(python_version.split(".")[0:2])

if not python_path:
    raise RuntimeError("Could not determine python path!")

config_root = Path(PROJECT_ROOT_CONFIG)
config_root.mkdir(exist_ok=True)
settings_file = config_root / Path(SETTINGS_FILE)

venv_base = Path(python_path).parents[1]

extra_path = (
    venv_base / "lib" / f"python{python_minor_version}" / "site-packages"
)
config = CONF_FMT_STRING.format(
    python_path=python_path, python_extra_path=extra_path
)

for path in [extra_path, python_path]:
    if not path.exists():
        raise RuntimeError(f"The path {path} does not exist!")

settings_file.write_text(config)
print(f"Writing to {settings_file} the config:")
print(config)
