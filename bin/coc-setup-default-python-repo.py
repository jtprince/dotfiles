#!/usr/bin/env python

import json
import os
import subprocess
from pathlib import Path


_owlet_pyproject_file = Path(os.environ["OWLET_PYPROJECT_FILE"]).resolve()

ISORT_ARGS = dict(
    owlet_old=f"--apply -rc -sp {_owlet_pyproject_file} -sl".split(),
    owlet_new=f"--sp {_owlet_pyproject_file}".split(),
    personal=[],
)
OWLET_CURRENT = "owlet_old"


def is_owlet_repo():
    return Path("charts").exists()


def get_isort_args():
    key = OWLET_CURRENT if is_owlet_repo() else "personal"
    return ISORT_ARGS[key]


DEFAULTS = {
    "python.linting.pylintEnabled": True,
    "python.linting.flake8Enabled": True,
    "python.linting.enabled": True,
    "python.jediEnabled": False,
}


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

for path in [extra_path, python_path]:
    if not path.exists():
        raise RuntimeError(f"The path {path} does not exist!")

python_path = {"python.pythonPath": str(python_path)}
autocomplete_extra_paths = {"python.autoComplete.extraPaths": [str(extra_path)]}
isort_args = {"python.sortImports.args": get_isort_args()}


config = dict(DEFAULTS, **python_path, **autocomplete_extra_paths, **isort_args)
config_str = json.dumps(config, indent=4)


settings_file.write_text(config_str)
print(f"Writing to {settings_file} the config:")
print(config_str)
