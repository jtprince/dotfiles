#!/usr/bin/env python

import argparse
import dataclasses
import re
from collections import defaultdict
from pathlib import Path

local_wesnoth_dir = Path.home() / ".local/share/wesnoth/"

# e.g., "TRoW-A Summer of Storms Turn 8 hd.gz"
turn_save_re = re.compile(r"(\w+?)\-(.*)?\s+Turn\s+(\d+)(.*)\.gz")

turn_auto_save_re = re.compile(r"(\w+?)\-(.*)?\-Auto\-Save(\d+)\.gz")

# eg. "TRoW-Clearwater Port replay 20230913-030858.gz"
replay_save_re = re.compile(r"(\w+?)\-(.*)?\s+replay\s+([\d+\-]+)\.gz")

# e.g., "TRoW-Clearwater Port.gz"
episode_start_re = re.compile(r"(\w+?)\-(.*)\.gz")


@dataclasses.dataclass(frozen=True)
class WesnothSave:
    name: str
    campaign: str | None = None
    episode: str | None = None
    turn: int | None = 0
    save_identifier: str | None = None
    replay_timestamp: str | None = None
    auto_save: bool = False

    @classmethod
    def from_name(cls, name):
        campaign, episode, turn, save_identifier, replay_timestamp = (
            None,
            None,
            None,
            None,
            None,
        )
        auto_save = False

        if match := turn_save_re.match(name):
            campaign, episode, turn_str, save_identifier = match.groups()
            turn = int(turn_str)
        elif match := turn_auto_save_re.match(name):
            campaign, episode, turn_str = match.groups()
            auto_save = True
            turn = int(turn_str)
        elif match := replay_save_re.match(name):
            campaign, episode, replay_timestamp = match.groups()
            turn = None
        elif match := episode_start_re.match(name):
            campaign, episode = match.groups()
            turn = 0
        else:
            raise ValueError(f"Could not parse {name}")

        return cls(
            name=name,
            campaign=campaign,
            episode=episode,
            turn=turn,
            save_identifier=save_identifier,
            replay_timestamp=replay_timestamp,
            auto_save=auto_save,
        )

    def is_replay(self):
        return replay_timestamp is not None

    def is_episode_start(self):
        return turn == 0

    def is_deliberate_save(self):
        return not (save.is_replay() or self.auto_save)

    @classmethod
    def sort_saves(cls, saves):
        if len({(save.campaign, save.episode) for save in saves}) > 1:
            raise ValueError("Can only sort saves from a single campaign and episode")
        turned_saves = [save for save in saves if save.turn is not None]
        return list(sorted(turned_saves, key=lambda save: save.turn))

    @classmethod
    def last_deliberate_saves(cls, saves, n=1):
        """returns the latest n saves."""
        sorted_saves = cls.sort_saves(saves)
        return sorted_saves[-n:]


def is_version_dir(file):
    """Finds the directory like '1.16'"""
    return file.is_dir() and any(char.isdigit() for char in file.name)


version_dir = next(file for file in local_wesnoth_dir.iterdir() if is_version_dir(file))

default_save_dir = local_wesnoth_dir / version_dir / "saves"


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("--save_dir", type=Path, default=default_save_dir)
args = parser.parse_args()

save_dir = args.save_dir

saves = [
    WesnothSave.from_name(file.name) for file in save_dir.iterdir() if file.is_file()
]

saves_by_campaign_and_episode = defaultdict(list)
for save in saves:
    saves_by_campaign_and_episode[(save.campaign, save.episode)].append(save)

keep = set()
for key, saves in saves_by_campaign_and_episode.items():
    campaign, episode = key
    last_saves = WesnothSave.last_deliberate_saves(saves, 2)
    auto_saves = [save for save in saves if save.auto_save]
    keep.update([id(save) for save in last_saves])
    keep.update([id(save) for save in auto_saves])

    to_delete = [save for save in saves if id(save) not in keep]

    for save in to_delete:
        save_path = save_dir / save.name
        print("deleting", str(save_path))
        save_path.unlink(missing_ok=True)
