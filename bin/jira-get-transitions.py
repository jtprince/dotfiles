#!/usr/bin/env python

import argparse
import os
from collections import defaultdict

# pip install iso8601
# import iso8601
import requests
import yaml

parser = argparse.ArgumentParser()
parser.add_argument("projects", nargs="+", help="project id or key")
parser.add_argument(
    "--api-key",
    default=os.environ.get("JIRA_API_KEY"),
    help="defaults to $JIRA_API_TOKEN",
)
parser.add_argument(
    "--login", required=True, help="your login, typically an email address"
)
parser.add_argument(
    "--issue-type",
    default="task",
    help="the issue type (hint --list-issue-types)",
)
parser.add_argument(
    "--list-issue-types", action="store_true", help="list the issue types"
)

args = parser.parse_args()

DOMAIN_NAME = "https://owletcare.atlassian.net"

PROJECT_STATUSES_FMTSTR = (
    f"{DOMAIN_NAME}/rest/api/2/project/" + "{project_id}/statuses"
)

if not args.api_key:
    parser.error("Must have a valid --api-key (or set $JIRA_API_KEY)")

if not args.login:
    parser.error("Must provide user login (email associated with api key)")


data = defaultdict(dict)
for project_id in args.projects:
    url = PROJECT_STATUSES_FMTSTR.format(project_id=project_id)
    response = requests.get(url, auth=(args.login, args.api_key))
    response_data = response.json()

    if args.list_issue_types:
        for issue_type in response_data:
            data[project_id][int(issue_type["id"])] = issue_type["name"]
        continue

    for issue_type in response_data:
        if issue_type["name"].lower() == args.issue_type.lower():
            for status in issue_type["statuses"]:
                data[project_id][int(status["id"])] = status["name"]
            continue


print(yaml.dump(dict(data)))
