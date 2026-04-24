# Use prefect-cli

## Install

```toml
-----------------------------
# add to ~/.config/uv/uv.toml
-----------------------------
[[index]]
name = "Enveda"
url = "https://pypi.enveda.io/simple/"
default = true
```

```bash
uv tool install prefect-cli
```

## Submit

```bash
prefect-cli start \
  --deployment enveda-ms.batch-feature-calling-custom-pairs/prod-ms_8_1 \
  some_file.json
# will use 'some_file' as run name unless use `--name better_run_name`
```

some_file.json

```json
{
  "params": {
    "ms_version": "ms_8_1",
    "run_options": {
      "database": "ms_8_1"
    },
    "msrun_id_pairs": [
      [
        "MSB90714",
        "MSB91892"
      ],
      [
        "MSB53664",
        "MSB53742"
      ]
    ]
  }
}
```
