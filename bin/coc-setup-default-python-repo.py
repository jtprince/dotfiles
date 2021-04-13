#!/usr/bin/env python

import argparse
import json
import os
import subprocess
import textwrap
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--skip-root-check", action="store_true")
args = parser.parse_args()


_OWLET_PYPROJECT_FILE = Path(os.environ["OWLET_PYPROJECT_FILE"]).resolve()
project_root = str(Path.cwd())

ISORT_ARGS = dict(
    owlet=f"--src {project_root} --settings-path {_OWLET_PYPROJECT_FILE}".split(),
    personal=[],
)
PYLINT_ARGS = dict(
    owlet=f"--rcfile {_OWLET_PYPROJECT_FILE}".split(),
    personal=["--rcfile", str(Path.home() / ".config/pylintrc")],
)


def is_owlet_repo():
    """The current location represents an Owlet repo."""
    return Path("charts").exists()


def get_isort_args():
    """Get the isort args that should be used.

    These are modulated based on whether it's an Owlet repo or personal.
    """
    key = "owlet" if is_owlet_repo() else "personal"
    return ISORT_ARGS[key]


def get_pylint_args():
    """Get the pylint args that should be used.

    These are modulated based on whether it's an Owlet repo or personal.
    """
    key = "owlet" if is_owlet_repo() else "personal"
    return PYLINT_ARGS[key]


DEFAULTS = {
    "python.linting.pylintEnabled": True,
    "python.linting.flake8Enabled": True,
    "python.linting.enabled": True,
    "python.jediEnabled": False,
}


PROJECT_ROOT_CONFIG = ".vim"
SETTINGS_FILE = "coc-settings.json"

if (not args.skip_root_check) and not Path(".git").exists():
    info = f"""

    Must be in a project root!

    HINT: if you want to initialize and there's no .git, then:

        {Path(__file__).name} --skip-root-check
    """
    raise RuntimeError(textwrap.dedent(info))


def _ensure_exists(path):
    """Return the path after ensuring it exists."""
    if not path.exists():
        raise RuntimeError(f"The path {path} does not exist!")
    return path


def get_python_path():
    """Return the path of `pyenv which python`."""
    python_path = Path(subprocess.getoutput("pyenv which python"))
    if not python_path:
        raise RuntimeError("Could not determine python path!")
    return _ensure_exists(python_path)


def get_python_major_minor_version():
    """Gets the major.minor version of python (e.g., 3.8)."""
    python_version = subprocess.getoutput("python --version").split()[-1]

    # e.g., 3.8.5 -> 3.8
    return ".".join(python_version.split(".")[0:2])


def _get_virtualenv_path(python_path, python_major_minor_version):
    venv_base = Path(python_path).parents[1]

    extra_path = (
        venv_base
        / "lib"
        / f"python{python_major_minor_version}"
        / "site-packages"
    )
    return _ensure_exists(extra_path)


def _get_viable_settings_path(settings_dir):
    """Returns a settings path with created settings_dir."""
    config_root = Path(settings_dir)
    config_root.mkdir(exist_ok=True)
    return config_root / Path(SETTINGS_FILE)


def _write_settings(path, data):
    config_str = json.dumps(data, indent=4)

    path.write_text(config_str)
    print(f"Wrote to {path}:")
    print(config_str)


def create_and_write_cocfile():
    """Generates and writes out the cocfile."""
    python_path = get_python_path()
    python_major_minor_version = get_python_major_minor_version()

    settings_file = _get_viable_settings_path(PROJECT_ROOT_CONFIG)

    virtualenv_path = _get_virtualenv_path(
        python_path, python_major_minor_version
    )

    # Until coc python loses that stupid 3.9 version warning, let's use a
    # warning-less python
    python_no_warnings = subprocess.getoutput(
        f"python-create-no-warning-python.py {str(python_path)}"
    ).strip()

    extra_settings = {
        "python.pythonPath": python_no_warnings,
        "python.autoComplete.extraPaths": [str(virtualenv_path)],
        "python.sortImports.args": get_isort_args(),
        "python.linting.pylintArgs": get_pylint_args(),
    }

    config = dict(DEFAULTS, **extra_settings)
    _write_settings(settings_file, config)


if __name__ == "__main__":
    create_and_write_cocfile()
