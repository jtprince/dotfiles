#!/usr/bin/env python


from pathlib import Path
import subprocess

import os

MEGA = Path.home() / "MEGA"

token_path = (
    MEGA
    / "env"
    / "cloud-and-apis"
    / "github"
    / "access_tokens"
    / "owlet_repo_and_read_package.token.txt"
)

env = dict(os.environ)
env["GITHUB_USERNAME"] = "jtprince"
env["GITHUB_ACCESS_TOKEN"] = token_path.read_text().strip()
print(env)

expect_cmd = "poetry-install-with-github-access-token.exp"

response = subprocess.run([expect_cmd], capture_output=True, text=True, env=env)
print(response.stdout)
