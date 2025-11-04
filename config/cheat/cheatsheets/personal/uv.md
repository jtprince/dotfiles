## Manage python installations

uv python install 3.10
uv python list
uv python pin --global <version>

## Create new project	
uv init <project>

## Use private repo in your pyproject.toml

```
[[tool.uv.index]]
name = "Enveda"
url = "https://pypi.dev.enveda.io/simple/"
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
