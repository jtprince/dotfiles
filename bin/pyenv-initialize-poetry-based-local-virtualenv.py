#!/usr/bin/env python

import re
import subprocess
from pathlib import Path

pyproject = "pyproject.toml"

python_version_re = re.compile(r"^python\s*=\s*[\"']\^?([\d\.]+)[\"']")
repo_name_re = re.compile(r"^name\s*=\s*[\"']([\w\-]+)[\"']")

version_match = next(
    filter(
        lambda val: val, map(python_version_re.match, Path(pyproject).open())
    )
)

project_name_match = next(
    filter(lambda val: val, map(repo_name_re.match, Path(pyproject).open()))
)


project_name = project_name_match.group(1)
required_minimum_version = version_match.group(1)


def get_available_pyenv_python_versions():
    """ Returns all available pyenv python versions, in ascending order. """
    response = subprocess.run(
        ["pyenv", "versions"], text=True, capture_output=True
    )
    available = []
    for line in response.stdout.split("\n"):
        chars = line.strip()
        if "/" not in chars:
            if chars.replace(".", "").isdigit():
                available.append(chars)

    return available


available = get_available_pyenv_python_versions()

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
    response = subprocess.run(
        ["pyenv", "virtualenv", best_version, suggested_virtualenv],
        capture_output=True,
        text=True,
    )
    print(response.stdout)

    # associate with the repo
    response = subprocess.run(
        ["pyenv", "local", suggested_virtualenv], capture_output=True, text=True
    )
    local_python_virtalenv = get_local_python_virtualenv()
    if local_python_virtalenv:
        print(f"Using local python virtualenv: {local_python_virtalenv}")
