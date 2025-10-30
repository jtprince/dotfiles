poetry source add --priority=primary Enveda https://packagesncus01.z14.web.core.windows.net/simple/ && \
poetry source add --priority=supplemental PyPI && \
poetry lock --no-update


[[tool.poetry.source]]
name = "Enveda"
url = "https://packagesncus01.z14.web.core.windows.net/simple/"
priority = "primary"


[[tool.poetry.source]]
name = "PyPI"
priority = "supplemental"


poetry lock --no-update
