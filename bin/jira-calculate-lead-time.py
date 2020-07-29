#!/usr/bin/env python

import argparse
import os
from dataclasses import dataclass

# pip install iso8601
import iso8601
import requests


@dataclass
class Transition:
    # from is a keyword so can't be used naked; ugly :/
    from_: str
    to: str

    def matches_item(self, item):
        matches_from = (item.get('fromString') == self.from_) if self.from_ else True
        matches_to = (item.get('toString') == self.to) if self.to else True
        return matches_from and matches_to


BEGIN_TRANSITION = Transition(None, 'In Progress')

# prefer end transitions in the order given
END_TRANSITIONS = [Transition(None, 'Released'), Transition(None, 'Done'), Transition(None, 'Staged')]


parser = argparse.ArgumentParser()
parser.add_argument("issues", nargs="+", help="the issues.  Make sure to include prefix (like 'WMS-123')")
parser.add_argument(
    "--api-key", default=os.environ.get("JIRA_API_KEY"), help="defaults to env var JIRA_API_TOKEN"
)
parser.add_argument("--login", help="your login, typically an email address")
args = parser.parse_args()

BASE_URL = "https://3plcentral.atlassian.net/rest/api/2/issue/"

if not args.api_key:
    parser.error("Must have a valid --api-key (or set $JIRA_API_KEY)")

if not args.login:
    parser.error("Must provide user login (email associated with api key)")


def get_histories(histories, transition):
    """ Returns a list of all history dicts with transitions specified by from and to. """
    return [
        history for history in histories
        if any(transition.matches_item(item) for item in history.get('items', []))
    ]


for issue in args.issues:
    url = BASE_URL + issue
    response = requests.get(url, params=dict(expand='changelog'), auth=(args.login, args.api_key))
    data = response.json()
    changelog = data.get('changelog', {})
    histories = changelog.get('histories', {})

    # not completely efficient, but efficiency probably doesn't matter for this use case
    begin_histories = get_histories(histories, BEGIN_TRANSITION)

    for end_transition in END_TRANSITIONS:
        end_histories = get_histories(histories, end_transition)
        if end_histories:
            break

    if not (begin_histories and end_histories):
        delta_in_days = None
    else:
        first_begin = min(begin_histories, key=lambda history: history['created'])

        last_end = max(end_histories, key=lambda history: history['created'])

        begin = iso8601.parse_date(first_begin['created'])
        end = iso8601.parse_date(last_end['created'])

        delta = end - begin

        delta_in_days = delta.total_seconds() / (3600 * 24)

    print("\t".join([issue, str(delta_in_days)]))
