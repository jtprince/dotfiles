#!/usr/bin/env python

import argparse
import os
import traceback


try:
    from github import Github
except ModuleNotFoundError:
    traceback.print_exc()
    print("==> hint: pip install PyGithub")
    exit(1)


github_token = os.environ.get("GITHUB_TOKEN")
parser = argparse.ArgumentParser()
parser.add_argument("organization", help="name of the github org")
parser.add_argument(
    "--token",
    default=github_token,
    help="The github token, defaults to $GITHUB_TOKEN",
)
args = parser.parse_args()


gh = Github(github_token)

org = gh.get_organization(args.organization)
for repo in org.get_repos():
    print(repo.name)
