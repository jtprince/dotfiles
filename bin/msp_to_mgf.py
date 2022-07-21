#!/usr/bin/env python3

import re
import argparse
from pathlib import Path
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument(
    "msp_paths", type=Path, nargs="+", help="one or more .msp files"
)
args = parser.parse_args()


def _passthrough(val):
    return val


def __passthrough():
    return _passthrough


def _convert_charge(val):
    try:
        int_val = int(val)
        # negative value will take care of itself
        sign = "+" if int_val > 0 else ""
        return f"{sign}{int_val}"
    except:
        return val


CONVERT_HEADER_KEY = defaultdict(
    __passthrough,
    {
        "PRECURSORMZ": "PRECURSOR",
        "PRECURSOR_CHARGE": "CHARGE",
    },
)

# Given in terms of the MSP key, not the MGF key
CONVERT_HEADER_VALUE = defaultdict(
    __passthrough,
    {
        "PRECURSOR_CHARGE": _convert_charge,
    },
)

KEYVAL_DELIMITER = re.compile(r":\s?")


def convert_msp_spectrum_to_mgf_lines(lines):
    peak_index = None
    header_data = {}
    for index, line in enumerate(lines):
        if line.startswith("NUM PEAKS:"):
            peak_index = index + 1
            break
        key, value = re.split(KEYVAL_DELIMITER, line, maxsplit=1)
        header_data[key] = value

    peak_lines = lines[peak_index:]
    mgf_header_data = convert_msp_header_to_mgf_header(header_data)
    header_lines = [f"{key}={val}" for key, val in mgf_header_data.items()]

    return header_lines + ["BEGIN IONS"] + peak_lines + ["END IONS"]


def convert_key_val(key, val):
    callable_or_string = CONVERT_HEADER_KEY[key]
    if isinstance(callable_or_string, str):
        new_key = callable_or_string
    else:
        new_key = callable_or_string(key)

    new_val = CONVERT_HEADER_VALUE[key](val)
    return (new_key, new_val)


def convert_msp_header_to_mgf_header(header_data):
    mgf_header = {"COM": header_data.get("NAME", "")}
    mgf_header.update(
        dict(convert_key_val(key, val) for key, val in header_data.items())
    )
    return mgf_header


for path in args.msp_paths:
    mgf_path = path.with_suffix(".mgf")
    with mgf_path.open("w") as outfile:
        with path.open() as infile:
            spectrum_lines = []
            for line in infile:
                stripped = line.rstrip()
                if stripped:
                    spectrum_lines.append(stripped)
                else:
                    mgf_lines = convert_msp_spectrum_to_mgf_lines(
                        spectrum_lines
                    )
                    print("\n".join(mgf_lines), file=outfile)
                    print("", file=outfile)
                    spectrum_lines = []

        mgf_lines = convert_msp_spectrum_to_mgf_lines(spectrum_lines)
        print("\n".join(mgf_lines), file=outfile)
