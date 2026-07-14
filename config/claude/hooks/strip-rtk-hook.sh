#!/bin/sh
# SessionStart self-heal: remove any resurrected "rtk ..." hook entries from
# settings.json. Stale long-lived Claude Desktop/Cowork processes can write
# back an old in-memory settings snapshot that still contains the rtk
# PreToolUse block (rtk itself is uninstalled). See memory:
# rtk-hook-recurrence-root-cause. Writes only when an rtk entry is present.
f="$HOME/.claude/settings.json"
[ -r "$f" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

if ! jq -e '[.hooks[]?[]?.hooks[]?.command // ""] | any(test("^rtk( |$)"))' "$f" >/dev/null 2>&1; then
  exit 0  # no rtk entries — nothing to do
fi

cleaned=$(jq '.hooks |= map_values(map(select([.hooks[]?.command // ""] | any(test("^rtk( |$)")) | not)))' "$f") || exit 0
# printf > "$f" truncates in place, preserving the ~/.claude symlink into dotfiles
printf '%s\n' "$cleaned" > "$f"
printf '%s self-heal: stripped resurrected rtk hook block\n' "$(date '+%Y-%m-%dT%H:%M:%S')" >> "$HOME/.claude/rtk-shim.log" 2>/dev/null
