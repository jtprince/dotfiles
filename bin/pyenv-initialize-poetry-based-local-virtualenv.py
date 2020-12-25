#!/usr/bin/env python

import argparse
import re
import subprocess
from pathlib import Path

REQUIRED_NEOVIM_PACKAGES = ["neovim", "black", "isort", "pylint", "flake8"]
COC_SETUP_CMD = "coc-setup-default-python-repo.py"
PIP_INSTALL_CMD = ["pip", "install"]
POETRY_INSTALL_CMD = ["poetry", "install"]


INSTALLATION_OPTIONS = ["neovim", "poetry", "testing"]


def run(cmd):
    """Run the given command and return captured output.

    subprocess.run with text=True and capture_output=Truereturns

    Returns:
        response.stdout
    """
    reply = subprocess.run(cmd, text=True, capture_output=True, check=True)
    return reply.stdout


parser = argparse.ArgumentParser()
parser.add_argument(
    "-c", "--coc", action="store_true", help="install coc settings file"
)
parser.add_argument(
    "-n",
    "--neovim",
    action="store_true",
    help="install neovim and related pip packages",
)
parser.add_argument(
    "-p", "--poetry", action="store_true", help="run poetry install"
)
parser.add_argument(
    "-t",
    "--testing",
    action="store_true",
    help="pip install pytest and pytest-cov",
)
parser.add_argument(
    "-a", "--all", action="store_true", help="install all the things"
)

args = parser.parse_args()
params = vars(args)
if params.pop("all"):
    for key in INSTALLATION_OPTIONS:
        params[key] = True


PYPROJECT = "pyproject.toml"

python_version_re = re.compile(r"^python\s*=\s*[\"'][~\^]?([\d\.]+)[\"']")
repo_name_re = re.compile(r"^name\s*=\s*[\"']([\w\-]+)[\"']")

version_match = next(
    filter(
        lambda val: val, map(python_version_re.match, Path(PYPROJECT).open())
    )
)

project_name_match = next(
    filter(lambda val: val, map(repo_name_re.match, Path(PYPROJECT).open()))
)


project_name = project_name_match.group(1)
required_minimum_version = version_match.group(1)


def get_available_pyenv_python_versions():
    """ Returns all available pyenv python versions, in ascending order. """
    reply = run(["pyenv", "versions", "--bare"])
    available_ = []
    for line in reply.split("\n"):

        chars = line.strip()
        if "/" not in chars:
            if chars.replace(".", "").isdigit():
                available_.append(chars)

    return available_


available = get_available_pyenv_python_versions()

print(available)
print(required_minimum_version)
best_version = next(
    version
    for version in reversed(available)
    if version.startswith(required_minimum_version)
)

suggested_virtualenv = f"{project_name}-{best_version}"


def get_local_python_virtualenv():
    python_version = Path(".python-version")
    if python_version.exists():
        return python_version.read_text().strip()
    else:
        return None


local_python_virtalenv = get_local_python_virtualenv()
if local_python_virtalenv:
    if suggested_virtualenv == local_python_virtalenv:
        print(f"Virtual env {suggested_virtualenv} already setup!")
    else:
        print(
            "Suggested virtualenv not equal to actual: "
            f"{suggested_virtualenv} != {local_python_virtalenv}"
        )
else:
    # this assumes the virtual env does not *ALREADY* exist
    # TODO: check existing virtualenvs to see if it already exists

    # make the virtualenv
    response = run(["pyenv", "virtualenv", best_version, suggested_virtualenv])
    print(response)

    # associate with the repo
    response = run(["pyenv", "local", suggested_virtualenv])
    local_python_virtalenv = get_local_python_virtualenv()
    if local_python_virtalenv:
        print(f"Using local python virtualenv: {local_python_virtalenv}")

if params["coc"]:
    response = run(COC_SETUP_CMD)
    print(response)

if params["neovim"]:
    install_all = PIP_INSTALL_CMD + REQUIRED_NEOVIM_PACKAGES
    response = run(install_all)
    print(response)

if params["poetry"]:
    run(PIP_INSTALL_CMD + ["poetry"])
    response = run(POETRY_INSTALL_CMD)
    print(response)
