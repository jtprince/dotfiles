#!/usr/bin/env python

import argparse
import time

# pip install pyteomics lxml
from pyteomics import mzml

parser = argparse.ArgumentParser(description="read all spectra")
parser.add_argument("mzml_path")


def get_spectrum_summary(spectrum: dict):
    retention_time = spectrum["scanList"]["scan"][0]["scan start time"]
    mzs = spectrum["m/z array"]
    intensities = spectrum["intensity array"]

    return {
        "rt (minutes)": retention_time,
        "first_pair": (mzs[0], intensities[0]),
        "last_pair": (mzs[-1], intensities[-1]),
    }


def get_spectrum_summaries(mzml_path: str):
    """Read an mzml file."""

    with mzml.read(mzml_path) as msrun:

        return [
            get_spectrum_summary(spectrum)
            for spectrum in msrun
            if spectrum["ms level"] == 1
        ]


if __name__ == "__main__":
    args = parser.parse_args()
    start_time = time.time()
    summaries = get_spectrum_summaries(args.mzml_path)
    elapsed = time.time() - start_time
    print(f"Internal elapsed: {elapsed:.3f} sec")
    print("spectrum  0:", summaries[0])
    print("spectrum -1:", summaries[-1])
