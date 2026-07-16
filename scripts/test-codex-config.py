#!/usr/bin/env python
"""Acceptance checks for dotfile-managed Codex configuration."""

from __future__ import annotations

import json
import subprocess
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "config/codex/config.toml"
HOOKS = ROOT / "config/codex/hooks.json"
RULES = ROOT / "config/codex/rules/default.rules"
CLEAN_FILTER = ROOT / "config/codex/clean-config.py"
SUPPORTED_HOOKS = {
    "SessionStart",
    "PreToolUse",
    "UserPromptSubmit",
    "PostToolUse",
    "Stop",
}


def run(*args: str, input_text: str | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=ROOT,
        check=True,
        input=input_text,
        text=True,
        capture_output=True,
    )


def test_config() -> None:
    config = tomllib.loads(CONFIG.read_text())
    assert config["approval_policy"] == "on-request"
    assert config["sandbox_mode"] == "workspace-write"
    assert config["features"]["hooks"] is True
    assert config["sandbox_workspace_write"]["network_access"] is False
    assert config["tui"]["notifications"] == ["approval-requested"]
    assert config["notify"] == ["kitty-agent-attention"]
    assert set(config["mcp_servers"]) == {
        "serena",
        "headroom",
        "tokensave",
        "cavemem",
    }
    assert config["mcp_servers"]["serena"]["args"] == [
        "start-mcp-server",
        "--context=codex",
        "--project-from-cwd",
    ]


def test_hooks() -> None:
    hooks = json.loads(HOOKS.read_text())["hooks"]
    assert set(hooks) == SUPPORTED_HOOKS
    encoded = json.dumps(hooks)
    for forbidden in ("SessionEnd", "Notification", "strip-rtk", "context-mode"):
        assert forbidden not in encoded
    assert "--client=codex" in encoded
    assert "--ide codex" in encoded


def execpolicy(*command: str) -> dict[str, object]:
    result = run(
        "codex",
        "execpolicy",
        "check",
        "--rules",
        str(RULES),
        "--",
        *command,
    )
    return json.loads(result.stdout)


def test_rules() -> None:
    guarded = (
        ("git", "commit", "-m", "test"),
        ("git", "push", "origin", "main"),
        ("gh", "pr", "create", "--draft"),
        ("gh", "pr", "merge", "42"),
        ("gh", "release", "create", "v1"),
        ("git", "add", "-A"),
        ("git", "add", "--all"),
        ("git", "add", "."),
        ("git", "add", ":/"),
    )
    allowed = (
        ("git", "add", "src/app.py"),
        ("git", "add", "-u"),
        ("git", "add", "-p"),
    )
    for command in guarded:
        assert execpolicy(*command)["decision"] == "prompt", command
    for command in allowed:
        assert "decision" not in execpolicy(*command), command


def test_filter() -> None:
    source = """model = "gpt-x"
approval_policy = "on-request"

[projects."/private/path"]
trust_level = "trusted"

[tui.model_availability_nux]
"gpt-x" = 1

[mcp_servers.serena]
command = "serena"

[[skills.config]]
path = "/tmp/model-skill/SKILL.md"
model = "keep-me"
"""
    filtered = run("python3", str(CLEAN_FILTER), input_text=source).stdout
    assert "gpt-x" not in filtered
    assert "/private/path" not in filtered
    assert 'approval_policy = "on-request"' in filtered
    assert "[mcp_servers.serena]" in filtered
    assert "[[skills.config]]" in filtered
    assert 'model = "keep-me"' in filtered


def test_installer_dry_run() -> None:
    config_command = (
        "git",
        "config",
        "--local",
        "--get-regexp",
        r"^filter\.",
    )
    before_result = subprocess.run(
        config_command,
        cwd=ROOT,
        check=False,
        text=True,
        capture_output=True,
    )
    assert before_result.returncode in (0, 1)
    output = run("python3", str(ROOT / "bin/dotfiles-configure"), "--dry").stdout
    after_result = subprocess.run(
        config_command,
        cwd=ROOT,
        check=False,
        text=True,
        capture_output=True,
    )
    assert after_result.returncode in (0, 1)
    assert before_result.stdout == after_result.stdout
    assert ".codex/config.toml" in output
    assert ".codex/hooks.json" in output
    assert ".codex/rules/default.rules" in output
    assert (ROOT / "config/agent/skills/link-check/SKILL.md").is_file()


def main() -> None:
    test_config()
    test_hooks()
    test_rules()
    test_filter()
    test_installer_dry_run()
    print("Codex config acceptance: ok")


if __name__ == "__main__":
    main()
