---
tags: [ python, uv ]
---
# uv tool: install Python CLIs into isolated envs, exes land in ~/.local/bin
# (see also: uvx for one-off runs without installing)

## Basics
uv tool install ruff                  # latest from index
uv tool install 'ruff==0.6.9'         # pinned (also 'ruff>=0.6')
uv tool install ruff --python 3.12    # choose interpreter for tool env
uv tool install mypy --with types-requests   # extra deps in same env
uv tool list                          # installed tools + their exes
uv tool list --show-paths --show-version-specifiers --show-with
uv tool upgrade ruff                  # respects original version spec
uv tool upgrade --all
uv tool uninstall ruff
uv tool dir                           # where tool envs live
uv tool dir --bin                     # where exes are linked
uv tool update-shell                  # add bin dir to PATH if missing

## Install from a local dir (the project itself)
cd ~/src/mytool
uv tool install .                     # snapshot: rebuilds only on reinstall
uv tool install -e .                  # editable: code edits live immediately
uv tool install --force .             # overwrite existing install / exes
uv tool install --reinstall .         # rebuild after code change (non-editable)
uv tool install -e ~/src/mytool       # path works from anywhere
uv tool install -e '.[extra1,extra2]' # with extras
# needs [project.scripts] in pyproject.toml for exes to appear:
#   [project.scripts]
#   mytool = "mytool.cli:main"

## Install from a git repo
uv tool install git+https://github.com/org/repo
uv tool install git+https://github.com/org/repo@v1.2.0        # tag
uv tool install git+https://github.com/org/repo@main          # branch
uv tool install git+https://github.com/org/repo@<sha>         # commit
uv tool install git+ssh://git@github.com/org/repo.git         # private via ssh
uv tool install 'git+https://github.com/org/repo#subdirectory=pkgs/cli'
uv tool upgrade repo                  # re-fetches branch head

## Expose exes from extra packages too
uv tool install jupyter-core --with-executables-from ipykernel,notebook

## Private index
uv tool install mytool --index https://pypi.enveda.io/simple/
