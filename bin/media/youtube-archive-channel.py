#!/usr/bin/env python

import argparse
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument(
    "channelname", help="the name of the channel youtube.com/<channel>/"
)
args = parser.parse_args()
channelname = args.channelname.lstrip("@")


channel_url = f"https://www.youtube.com/@{channelname}"
output_dir = Path(f"{channelname}-archived-videos")
output_dir.mkdir(exist_ok=True)

archive_file = output_dir / "download_archive.txt"

output_template = str(output_dir / "%(upload_date)s--%(title).200B.%(ext)s")


# crf controls file size mostly

# 28 very good
# 30 good
# 32 fair to good (slight softening, still legible text)
# 35 noticeable artifacts (text may blur, blocky backgrounds)

command = [
    "yt-dlp",
    "--verbose",
    "--download-archive",
    str(archive_file),
    "--output",
    output_template,
    "--format",
    "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4",
    "--merge-output-format",
    "mp4",
    "--write-info-json",
    "--write-thumbnail",
    "--embed-metadata",
    "--embed-thumbnail",
    "--postprocessor-args",
    "ffmpeg:-c:v libx265 -crf 30 -preset slow -c:a aac -b:a 64k",
    channel_url,
]

subprocess.run(command, check=True)
