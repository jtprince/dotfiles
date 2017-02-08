#!/usr/bin/env python3

import datetime
import json
import os
import sys
import time
from urllib.request import urlopen

PYPI_BASE_URL = "https://pypi.python.org/pypi/"
PYPI_JSON_EXT = "/json"
DOWNLOAD_POINT_DELIMITER = "    "
INDENT = "  "
PACKAGE_DISPLAY = "== {pkgname} === {downloads} downloads =="
DOWNLOAD_RATE_PRECISION = 1
TIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
HEADER = "version  releasedate  downloads  downloads/day"


class DownloadDataPoint:
    def __init__(self, downloads, version, upload_time):
        self.downloads = downloads
        self.version = version
        self.upload_time = upload_time

    def download_rate(self):
        """ Returns downloads per day as a float. """
        time_diff = datetime.datetime.utcnow() - self.upload_time
        return float(self.downloads) / int(time_diff.days)


def to_datetime(datetime_string):
    """ Converts to a datetime object. """
    return datetime.datetime(*time.strptime(datetime_string, TIME_FORMAT)[:6])


def get_download_stats(pkg_name):
    """ Returns a list of DownloadDataPoint objects. """
    url = PYPI_BASE_URL + pkg_name + PYPI_JSON_EXT
    data_points = []
    with urlopen(url) as infile:
        data = json.loads(infile.read())
        for release, release_data_list in data['releases'].items():
            release_data = release_data_list[0]
            data_points.append(
                DownloadDataPoint(
                    release_data['downloads'],
                    release,
                    to_datetime(release_data['upload_time']),
                ),
            )

    return data_points


def compare_packages(packages):

    indent = INDENT if (len(packages) > 1) else ""

    print(indent + HEADER)
    print(indent + "-" * len(HEADER))

    for pkg in packages:
        data_points = get_download_stats(pkg)
        total_downloads = sum(
            data_point.downloads for data_point in data_points
        )

        print(PACKAGE_DISPLAY.format(pkgname=pkg, downloads=total_downloads))

        longest_version = max(
            len(data_point.version) for data_point in data_points
        )

        data_points.sort(key=lambda data_point: data_point.upload_time)

        for data_point in data_points:
            padded_version = data_point.version.ljust(longest_version)

            download_point_row = [
                padded_version,
                data_point.upload_time.date(),
                data_point.downloads,
                round(data_point.download_rate(), DOWNLOAD_RATE_PRECISION)
            ]

            line = DOWNLOAD_POINT_DELIMITER.join(map(str, download_point_row))
            print(indent + line)
        print("")


if __name__ == "__main__":
    packages = sys.argv[1:]
    if not len(packages):
        scriptname = os.path.basename(sys.argv[0])
        print("usage: {} <pkg-name> ...".format(scriptname))
        print("output: table comparing download stats and download rate")
    else:
        compare_packages(packages)
