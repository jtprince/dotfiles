#!/usr/bin/env python

# requires:
#    termgraph
#    pyyaml
#    odfpy
# pipx install termgraph
# yay -S python-pyyaml
# yay -S python-odfpy

import argparse
import sys
from collections import defaultdict
from subprocess import PIPE, Popen

import pandas as pd
import yaml

choices = ["first", "second", "third", "fourth"]

parser = argparse.ArgumentParser()
parser.add_argument(
    "odf",
    help=(
        "ranked choice voting in .odf format. "
        "Assumes header row. "
        f"Assumes equivalent columns as: timestamp, person, {', '.join(choices)}"
    ),
)
args = parser.parse_args()

poll_data = pd.read_excel(args.odf, engine="odf")
poll_data.columns = ["timestamp", "person", *choices]
only_choices = poll_data.drop(columns=["person", "timestamp"])


def plot_horizontal_bar_plot(data, title):
    value_counts = data["activity"].value_counts()
    value_counts.rename("counts", inplace=True)
    value_counts.index.name = "activity"
    data_str = value_counts.to_csv(header=False)
    p = Popen(["termgraph", "--delim", ","], stdin=PIPE, stderr=PIPE)

    print(title)
    p.communicate(input=data_str.encode("utf-8"))[0]


def sort_people(people_choices, activities):
    activities_to_people = defaultdict(list)
    for person, choices in people_choices.items():
        first_match = next((choice for choice in choices if choice in activities), None)
        activities_to_people[first_match].append(person)
    return dict(activities_to_people)


def plot_all_choices(melted, choices):
    for end in range(1, len(choices) + 1):
        valid_choices = choices[0:end]
        subset = melted[melted["choice"].isin(valid_choices)]
        title = f"within top {end} choices"
        plot_horizontal_bar_plot(subset, title)


def write_person_per_activity(poll_data, unique_activities):
    per_person = (
        poll_data.drop(columns="timestamp").set_index("person").T.to_dict(orient="list")
    )

    for top_number in range(1, len(unique_activities)):
        print(f"Choosing top {top_number} most represented activities, generally")
        top_n = melted.activity.value_counts().index.tolist()[0:top_number]

        activities_to_people = sort_people(per_person, activities=top_n)
        yaml.dump(activities_to_people, sys.stdout, default_flow_style=False)
        print()


melted = pd.melt(only_choices, var_name="choice", value_name="activity")
unique_activities = melted.activity.dropna().unique().tolist()

plot_all_choices(melted, choices)
write_person_per_activity(poll_data, unique_activities)
