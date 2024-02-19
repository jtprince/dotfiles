#!/usr/bin/env python3

import re
import argparse
from pathlib import Path
from typing import List, Tuple, Optional


def _convert_charge(val: str) -> str:
    """Convert the charge to MGF valid charge.

    -1 -> -1 (no change)
    1 -> +1
    """
    try:
        int_val = int(val)
        # negative value will take care of itself
        sign = "+" if int_val > 0 else ""
        return f"{sign}{int_val}"
    except:
        return val


MSP_KEYVAL_DELIMITER_RE = re.compile(r":\s?")

# MSP -> MGF
# If not specified, will just uses the existing msp header.
CONVERT_HEADER_KEY = {
    "PRECURSORMZ": "PRECURSOR",
    "PRECURSOR_CHARGE": "CHARGE",
}

# Key is the **MSP** header NOT the MGF header.
# If no conversion function is given, will passe the value through as is.
CONVERT_HEADER_VALUE = {
    "PRECURSOR_CHARGE": _convert_charge,
}


def convert_msp_to_mgf_block(lines: List[str]) -> List[str]:
    """Converts msp lines for ONE spectrum into new set of mgf lines."""
    peak_index = None
    header_data = {}
    for index, line in enumerate(lines):
        if line.startswith("NUM PEAKS:"):
            peak_index = index + 1
            break
        key, value = re.split(MSP_KEYVAL_DELIMITER_RE, line, maxsplit=1)
        header_data[key] = value

    peak_lines = lines[peak_index:]
    mgf_header_data = convert_msp_header_to_mgf_header(header_data)
    header_lines = [f"{key}={val}" for key, val in mgf_header_data.items()]

    return header_lines + ["BEGIN IONS"] + peak_lines + ["END IONS"]


def convert_key_val(key: str, val: str) -> Tuple[str, str]:
    new_key = CONVERT_HEADER_KEY.get(key, key)
    callable = CONVERT_HEADER_VALUE.get(key, None)
    new_val = callable(val) if callable else val
    return (new_key, new_val)


def convert_msp_header_to_mgf_header(header_data):
    mgf_header = {"COM": header_data.get("NAME", "")}
    mgf_header.update(
        dict(convert_key_val(key, val) for key, val in header_data.items())
    )
    return mgf_header


def print_lines(lines, **kwargs):
    print("\n".join(lines), **kwargs)


def convert_msp_path(msp_path, mgf_path: Optional[Path] = None):
    """Converts an entire msp file into an mgf file.

    Only processes a single spectrum at a time to ensure that very little
    memory is consumed.
    """
    if mgf_path is None:
        mgf_path = msp_path.with_suffix(".mgf")

    with mgf_path.open("w") as outfile:
        with msp_path.open() as infile:
            spectrum_lines = []
            for line in infile:
                stripped = line.rstrip()
                if stripped:
                    spectrum_lines.append(stripped)
                else:
                    mgf_lines = convert_msp_to_mgf_block(spectrum_lines)
                    print_lines(mgf_lines, file=outfile, end="\n\n")
                    spectrum_lines = []

        # And print the last one since not triggered by extra newline
        mgf_lines = convert_msp_to_mgf_block(spectrum_lines)
        print_lines(mgf_lines, file=outfile)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="convert msp into mgf with little memory use"
    )
    parser.add_argument(
        "msp_paths", type=Path, nargs="+", help="one or more .msp files"
    )
    args = parser.parse_args()
    for path in args.msp_paths:
        convert_msp_path(path)
