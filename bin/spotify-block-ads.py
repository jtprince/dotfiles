#!/usr/bin/env python

# pip install --user yaml python-daemon

import subprocess
import time

import yaml

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

ADVERTISEMENT = ('Advertisement', 'Spotify')


def in_advertisement():
    info = subprocess.run("spotify-info", capture_output=True)
    song_data = yaml.safe_load(info.stdout)
    return song_data['xesam:title'] in ADVERTISEMENT


def get_spotify_sink():
    client_data = subprocess.run("pactl list short clients".split(), capture_output=True, encoding='utf-8').stdout
    channels = []
    for client_line in client_data.split("\n"):
        client_data = client_line.split("\t")
        client = client_data[-1]
        if client == 'spotify':
            channels.append(int(client_data[0]))

    channel_to_sink = {}
    sink_str = subprocess.run("pactl list short sink-inputs".split(), capture_output=True, encoding='utf-8').stdout
    for sink_line in sink_str.split("\n"):
        sink_data = sink_line.split("\t")
        if sink_data[0]:
            print(sink_data)
            channel = int(sink_data[2])
            sink = int(sink_data[1])
            channel_to_sink[channel] = sink

    spotify_sink = None
    for channel in channels:
        if channel in channel_to_sink:
            spotify_sink = channel_to_sink[channel]
            break

    return spotify_sink


def mute_sink(sink):
    subprocess.run(f"pactl set-sink-mute {sink} on".split())


def unmute_sink(sink):
    subprocess.run(f"pactl set-sink-mute {sink} off".split())


def run():
    in_advertisement_state = False
    while True:
        if in_advertisement():
            # print("IN ADVERTISEMENT")
            if not in_advertisement_state:
                # print("BEGINNING MUTE")
                in_advertisement_state = True
                spotify_sink = get_spotify_sink()
                mute_sink(spotify_sink)
        elif in_advertisement_state:
            # print("UNMUTING")
            spotify_sink = get_spotify_sink()
            unmute_sink(spotify_sink)
            in_advertisement_state = False

        time.sleep(1)


# pactl list sink-inputs
#   see: media.name
#   see: Sink: 4
# pactl set-sink-mute 4 toggle

if __name__ == '__main__':
    run()
