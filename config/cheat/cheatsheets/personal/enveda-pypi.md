# Enveda PyPI

Base URL: https://pypi.enveda.io/simple/

## Browse

```bash
# list all packages
curl -s https://pypi.enveda.io/simple/ | grep -oP '(?<=href=")[^"]+(?=/index.html")'

# list versions/files for a package
curl -s https://pypi.enveda.io/simple/ms-peak-gallery/

# check if a package exists (200 = yes, 404 = no)
curl -so /dev/null -w '%{http_code}' https://pypi.enveda.io/simple/ms-peak-gallery/
```

## pyproject.toml setup (uv)

```toml
[[tool.uv.index]]
name = "Enveda"
url = "https://pypi.enveda.io/simple/"
default = true

[tool.uv.sources]
my-package = { index = "Enveda" }
```

## Install

```bash
uv add my-package                  # after pyproject.toml setup above
uv add "my-package[extra]"         # with optional extras
uv pip install my-package -i https://pypi.enveda.io/simple/  # one-off
```

## Publish (via GitHub Actions)

Add `.github/workflows/uv-build-and-upload.yml`:

```yaml
name: uv-build-and-upload
on:
  workflow_dispatch:
  release:
    types: [published]
jobs:
  uv-build-and-upload:
    uses: enveda/reusable-workflows/.github/workflows/uv-build-and-upload.yml@v3
    secrets: inherit
    with:
      python-version: "3.10"
```

Trigger: create a GitHub release → workflow builds & uploads automatically.
Index refreshes on a ~10 min cron cycle after upload.
