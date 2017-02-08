#!/usr/bin/env python3

import datetime
import json
import sys
import time
from urllib.request import urlopen

PYPI_BASE_URL = "https://pypi.python.org/pypi/"
PYPI_JSON_EXT = "/json"


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
    return datetime.datetime(*time.strptime(datetime_string, "%Y-%m-%dT%H:%M:%S")[:6])


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


packages = sys.argv[1:]
indent = "  " if (len(packages) > 1) else ""

header = "version  releasedate  downloads  downloads/day"
print(indent + header)
print(indent + "-" * len(header))


for pkg in packages:
    data_points = get_download_stats(pkg)
    total_downloads = sum(data_point.downloads for data_point in data_points)
    print("{} ===> {} downloads".format(pkg, total_downloads))
    longest_version = max(len(data_point.version) for data_point in data_points)
    data_points.sort(key=lambda dp: dp.upload_time)
    for data_point in data_points:
        padded_version = data_point.version.ljust(longest_version)
        display = map(str, [padded_version, data_point.upload_time.date(), data_point.downloads, round(data_point.download_rate(), 1)])
        data = indent + "    ".join(display)
        print(data)
    print("")
