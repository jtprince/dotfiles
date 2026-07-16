#!/usr/bin/env python
"""Git clean filter for mutable Codex config state.

Reads TOML from stdin and removes values Codex writes as local UI/project state.
Formatting outside removed entries is preserved; live working-tree data is never
modified because Git clean filters only transform the blob sent to the index.
"""

from __future__ import annotations

import re
import sys


TABLE_HEADER = re.compile(r"^\s*\[{1,2}\s*(.+?)\s*\]{1,2}\s*(?:#.*)?$")
MODEL_KEY = re.compile(r"^\s*model\s*=")


def is_ephemeral_table(name: str) -> bool:
    """Return whether a TOML table contains machine-local Codex state."""
    return name == "tui.model_availability_nux" or name.startswith('projects."')


def clean(source: str) -> str:
    """Remove ephemeral root keys and tables while preserving other text."""
    output: list[str] = []
    skip_table = False
    at_root = True

    for line in source.splitlines(keepends=True):
        header = TABLE_HEADER.match(line)
        if header:
            at_root = False
            skip_table = is_ephemeral_table(header.group(1))
            if skip_table:
                while output and not output[-1].strip():
                    output.pop()
                continue

        if skip_table:
            continue
        if at_root and MODEL_KEY.match(line):
            continue
        output.append(line)

    return "".join(output)


def main() -> None:
    sys.stdout.write(clean(sys.stdin.read()))


if __name__ == "__main__":
    main()
