## Manage python installations

uv python install 3.10
uv python list
uv python pin --global <version>  # writes to uv config dir to use as uv default version

## My robust user-wide setup (e.g., in ~/.zprofile)
```
### In .zprofile: ####
export PYTHON_GLOBAL_VENV="$HOME/.local/uv-global"
export PATH="$PYTHON_GLOBAL_VENV/bin:$PATH"
######################

PYV=3.14
V=${PYV//.}
PREFIX="$HOME/.local/uv-global-$V"
uv python install "$PYV"
uv venv -p "$PYV" "$PREFIX"

PATH="$PREFIX/bin:$PATH" uv pip install -U pip setuptools wheel
PATH="$PREFIX/bin:$PATH" uv pip install argcomplete


ln -sfn "$PREFIX/bin/pip3" "$PREFIX/bin/pip"

ln -sfn "$PREFIX" "$HOME/.local/uv-global"
uv python pin --global "$PYV"
```

## Install using uv pip into the global python
uv pip install --python "$PYTHON_GLOBAL_VENV" pandas

## Create new project	
uv init <project>

## Use private repo in your pyproject.toml

```
[[tool.uv.index]]
name = "Enveda"
url = "https://pypi.enveda.io/simple/"
default = true
```

## Install dependencies	
uv sync

## Install deps with groups
uv sync --group dev --group test

## Install all groups	
uv sync --all-groups

## Install with extras	
uv sync --all-extras

## Add dependency	
uv add <package>

## Add dev dependency	
uv add --dev <package>

## Add with extras	
uv add <package>[extra1]

## Remove dependency	
uv remove <package>

## Update dependencies	
uv lock --upgrade

## Run command in venv	
uv run <command>

## Activate shell	
source .venv/bin/activate

## View Installed packages	
uv pip list 
uv tree

## Bump the version of a project	
uv version --bump <major|minor|patch>

## Use a tool e.g. ruff	
uvx ruff check
