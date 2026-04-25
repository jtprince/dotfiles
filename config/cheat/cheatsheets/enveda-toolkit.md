## Add to your pyproject.toml
```toml
[[tool.uv.index]]
name = "Enveda"
url = "https://pypi.enveda.io/simple/"
default = true

[tool.uv.sources]
enveda-toolkit = { index = "Enveda" }
```

Then:

```bash
uv add enveda-toolkit
```

Usage:

```python
from enveda_toolkit import get_databricks

dbx = get_databricks('prod')
df = dbx.query_df("select * from benchling_raw.bruker_mass_spec_run LIMIT 10")
```

```bash
enveda-table-manifest ms_8_1
Tables in enveda_prod.ms_8_1:
  calibration
  centroids
  contigs
  frame
  ms1
  ms1_tile
  ms2
  ms2_event
  ms2_event_ms1
  peak
  peak_bounding_box
  peak_groups
  peak_metrics
  peak_ms2
  peak_ms2_event
  peak_ms2_raw
  run

# for exact table details:
enveda-table-manifest ms_8_1 run
```
