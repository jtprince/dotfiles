---
tags: [ python, uv ]
---
# uvx = `uv tool run`: run a Python CLI in a cached throwaway env, no install
# (uses an installed tool's env if `uv tool install` already has it)

## Basics
uvx ruff check .                      # package name == command name
uvx ruff@0.6.9 check .                # pinned version
uvx ruff@latest check .               # force newest, ignore installed
uvx --python 3.12 black .             # choose interpreter
uvx --with pandas ipython             # extra deps in the env
uvx --isolated ruff                   # ignore installed tool env
uvx --refresh ruff                    # re-check index for new versions

## Command name != package name
uvx --from httpie http GET example.com
uvx --from 'jupyter-core' jupyter --version
uvx --from 'ruff==0.6.9' ruff check .

## Run from a local dir / repo
uvx --from . mytool --help            # current project (needs [project.scripts])
uvx --from ~/src/mytool mytool        # any path
uvx --with-editable . pytest          # run a tool against local pkg, editable
uvx --from git+https://github.com/org/repo mytool
uvx --from git+https://github.com/org/repo@v1.2.0 mytool
uvx --from 'git+https://github.com/org/repo#subdirectory=pkgs/cli' mytool

## Private index
uvx --index https://pypi.enveda.io/simple/ mytool

## uvx vs uv tool install vs uv run
# uvx          : one-off, cached env, nothing on PATH
# uv tool install : persistent, exe on PATH, upgrade with `uv tool upgrade`
# uv run       : runs inside current project's venv (project deps), not isolated
