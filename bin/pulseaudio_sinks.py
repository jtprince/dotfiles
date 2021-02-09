#!/usr/bin/env python

import dataclasses
import itertools
import subprocess


@dataclasses.dataclass(frozen=True)
class PASink:
    """A Pulseaudio Sink.

    Contains data from pactl, supplemented by pacmd.

    We start by grabbing the string info, but consider casting in future.
    """

    state: str
    name: str
    description: str
    driver: str
    sample_specification: str
    channel_map: str
    owner_module: str
    mute: str
    volume: str
    balance: str
    base_volume: str
    monitor_source: str
    latency: str
    flags: str
    properties: dict

    default: bool = False

    RUNNING = "RUNNING"
    DEFAULT_SINK_KEY = "Default sink name: "
    PROPERTIES_HEADER = "Properties:"
    PORTS_HEADER = "Ports:"

    @classmethod
    def get_default_sink_name(cls):
        pacmd_output = subprocess.check_output(
            "pacmd list sinks", text=True, shell=True
        )
        for line in pacmd_output.split("\n"):
            if line.startswith(cls.DEFAULT_SINK_KEY):
                return line.split(cls.DEFAULT_SINK_KEY)[-1]
        return None

    @classmethod
    def get_sinks(cls):
        output = subprocess.check_output(
            "pactl list sinks", text=True, shell=True
        )
        default_name = cls.get_default_sink_name()

        return [
            cls.from_pactl_chunk(line, default_name)
            for line in output.strip().split("\n\n")
        ]

    @classmethod
    def from_pactl_chunk(cls, chunk, default_name):
        stripped_lines = [line.strip() for line in chunk.split("\n")]
        # The sink_line
        stripped_lines.pop(0)

        def is_not_properties_line(line):
            return line != cls.PROPERTIES_HEADER

        header_lines = list(
            itertools.takewhile(is_not_properties_line, stripped_lines)
        )
        after_property_lines = list(
            itertools.dropwhile(is_not_properties_line, stripped_lines)
        )
        property_lines = list(
            itertools.takewhile(
                lambda line: line != cls.PORTS_HEADER,
                after_property_lines,
            )
        )
        to_submit = {}
        for line in header_lines:
            if line.startswith("balance"):
                key_in_caps, data = line.split(" ", 1)
            else:
                key_in_caps, data = line.split(": ", 1)
            key = key_in_caps.replace(" ", "_").lower()
            to_submit[key] = data

        properties = {}
        property_lines.pop(0)
        for line in property_lines:
            key, value = line.split(" = ")
            value.strip('"')
            properties[key] = value

        to_submit["properties"] = properties

        default = to_submit["name"] == default_name
        return cls(**to_submit, default=default)

    def is_running(self):
        return self.state == self.RUNNING

    def is_default(self):
        return self.default

    def set_default(self):
        subprocess.run(f"pactl set-default-sink {self.name}", shell=True)


if __name__ == "__main__":
    # print basic info about the sinks:
    for sink in PASink.get_sinks():
        print(sink.description)
        print("    " + sink.name)
        state = sink.state
        if sink.is_default():
            state += " ^^ *****************DEFAULT**************** ^^"
        print(state)
        print()
