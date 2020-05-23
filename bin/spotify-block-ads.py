#!/usr/bin/env python

# pip install --user yaml

import re
import subprocess
import time
from itertools import groupby

import yaml

ADVERTISEMENT = ('Advertisement', 'Spotify')

SINK_INPUT_RE = re.compile(r'Sink Input #(\d+)')

_SPOTIFY_REGEXS = [
    r'media\.role = "music"',
    r'media\.name = "Spotify"',
    r'application\.name = "Spotify"',
    r'application\.process.binary = "spotify"'
]
SPOTIFY_REGEXS = [re.compile(regex, re.MULTILINE) for regex in _SPOTIFY_REGEXS]


def in_advertisement():
    info = subprocess.run("spotify-info", capture_output=True)
    song_data = yaml.safe_load(info.stdout)
    return song_data['xesam:title'] in ADVERTISEMENT


def get_spotify_sink_input():
    """ Returns sink input # of the first spotify instance found. """
    client_data = subprocess.run("pactl list sink-inputs".split(), capture_output=True, text=True).stdout
    lines = client_data.split("\n")
    sink_inputs = [
        "\n".join(group) for not_matched, group in groupby(lines, lambda line: not line)
        if not not_matched
    ]
    for sink_input in sink_inputs:
        if all([regex.search(sink_input) for regex in SPOTIFY_REGEXS]):
            return SINK_INPUT_RE.match(sink_input).group(1)


def mute_sink(sink):
    subprocess.run(f"pactl set-sink-input-mute {sink} on".split())


def unmute_sink(sink):
    subprocess.run(f"pactl set-sink-input-mute {sink} off".split())


def run():
    in_advertisement_state = False
    while True:
        if in_advertisement():
            # print("IN ADVERTISEMENT")
            if not in_advertisement_state:
                # print("BEGINNING MUTE")
                in_advertisement_state = True
                sink_input = get_spotify_sink_input()
                mute_sink(sink_input)
        elif in_advertisement_state:
            # print("UNMUTING")
            sink_input = get_spotify_sink_input()
            unmute_sink(sink_input)
            in_advertisement_state = False

        time.sleep(1)


if __name__ == '__main__':
    # print(get_spotify_sink_input())
    run()


# ---
# `spotify-info`
# ---
# mpris:trackid: spotify:track:6a9SPVrXyrlVh5Fh08f8Bz
# mpris:length: 361706000
# mpris:artUrl: https://open.spotify.com/image/546f440ab718f50441342ef7a3223d7e1149b907
# xesam:album: Dirt
# xesam:albumArtist: Alice In Chains
# xesam:artist: Alice In Chains
# xesam:autoRating: 0.51
# xesam:discNumber: 1
# xesam:title: Rain When I Die
# xesam:trackNumber: 3
# xesam:url: https://open.spotify.com/track/6a9SPVrXyrlVh5Fh08f8Bz

# ---
# mpris:trackid: spotify:ad:000000012d833fa30000002031ad374e
# mpris:length: 20062000
# mpris:artUrl: ''
# xesam:album: ''
# xesam:albumArtist: ''
# xesam:artist: ''
# xesam:autoRating: 0.0
# xesam:discNumber: 0
# xesam:title: Advertisement
# xesam:trackNumber: 0
# xesam:url: https://open.spotify.com/ad/000000012d833fa30000002031ad374e


# ---
# `pactl list sink-inputs`
# ---
# Sink Input #81
#         Driver: protocol-native.c
#         Owner Module: 12
#         Client: 330
#         Sink: 1
#         Sample Specification: s16le 2ch 44100Hz
#         Channel Map: front-left,front-right
#         Format: pcm, format.sample_format = "\"s16le\""  format.rate = "44100"  ...
#         Corked: no
#         Mute: no
#         Volume: front-left: 65535 / 100% / -0.00 dB,   front-right: 65535 / 100% / -0.00 dB
#                 balance 0.00
#         Buffer Latency: 1021587 usec
#         Sink Latency: 26655 usec
#         Resample method: n/a
#         Properties:
#                 media.role = "music"
#                 media.name = "Spotify"
#                 application.name = "Spotify"
#                 native-protocol.peer = "UNIX socket client"
#                 native-protocol.version = "33"
#                 application.process.id = "388443"
#                 application.process.user = "jtprince"
#                 application.process.host = "kelsier"
#                 application.process.binary = "spotify"
#                 window.x11.display = ":0"
#                 application.language = "en_US.UTF-8"
#                 application.process.machine_id = "6b79ee180b6b41caadbfafef34d81be2"
#                 application.process.session_id = "1"
#                 application.icon_name = "spotify-client"
#                 module-stream-restore.id = "sink-input-by-media-role:music"

# Sink Input #87
#         Driver: protocol-native.c
#         Owner Module: 12
#         Client: 341
#         Sink: 1
#         Sample Specification: float32le 2ch 44100Hz
#         Channel Map: front-left,front-right
#         Format: pcm, format.sample_format = "\"float32le\""  format.rate = "44100"  ...
#         Corked: no
#         Mute: no
#         Volume: front-left: 65172 /  99% / -0.15 dB,   front-right: 65172 /  99% / -0.15 dB
#                 balance 0.00
#         Buffer Latency: 35532 usec
#         Sink Latency: 26447 usec
#         Resample method: copy
#         Properties:
#                 application.icon_name = "chromium-browser"
#                 media.name = "Playback"
#                 application.name = "Chromium"
#                 native-protocol.peer = "UNIX socket client"
#                 native-protocol.version = "33"
#                 application.process.id = "16085"
#                 application.process.user = "jtprince"
#                 application.process.host = "kelsier"
#                 application.process.binary = "chromium"
#                 application.language = "en_US.UTF-8"
#                 window.x11.display = ":0"
#                 application.process.machine_id = "6b79ee180b6b41caadbfafef34d81be2"
#                 application.process.session_id = "1"
#                 module-stream-restore.id = "sink-input-by-application-name:Chromium"
