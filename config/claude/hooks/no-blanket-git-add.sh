#!/usr/bin/env bash
# no-blanket-git-add.sh — PreToolUse hook (Bash) that intercepts blanket
# `git add` staging (`-A`, `--all`, bare `.`, `:/`) and asks the user to
# confirm before it runs.
#
# Why: blanket staging adds *untracked* files indiscriminately. It has swept
# large local binaries / scratch files into commits. Prefer staging explicit
# paths (`git add <file> …`). `git add -u` (tracked-only), `git add -p`,
# `git add <path>` and `git commit -a` are intentionally NOT caught.
#
# Hook contract (Claude Code PreToolUse):
#   - stdin: JSON with .tool_name and .tool_input.command
#   - stdout (this hook): JSON with hookSpecificOutput.permissionDecision="ask"
#     to force a confirmation prompt; exit 0.
#   - exit 0 with no output: allow silently.

set -uo pipefail

input="$(cat)"

# Extract tool_name + command (jq preferred; sed fallback so a parse failure
# never silently allows a blanket add).
if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
else
  tool="$(printf '%s' "$input" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"
fi

# Only guard Bash calls with a non-empty command.
[[ "$tool" != "Bash" && -n "$tool" ]] && exit 0
[[ -z "$cmd" ]] && exit 0

ask() {
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Blanket git add (-A / --all / . / :/) stages untracked files indiscriminately and has previously swept large binaries into a commit. Approve only if you really mean to stage everything; otherwise stage explicit paths: git add <file> ..."}}'
  exit 0
}

# Split the command into segments on && || ; | and newlines, so
# `cd x && git add -A` is caught and a `.` in an unrelated segment is not.
# (bash word-splitting on a custom IFS after normalizing the separators.)
normalized="${cmd//&&/$'\n'}"
normalized="${normalized//||/$'\n'}"
normalized="${normalized//;/$'\n'}"
normalized="${normalized//|/$'\n'}"

while IFS= read -r seg; do
  # trim leading whitespace
  seg="${seg#"${seg%%[![:space:]]*}"}"
  # only inspect `git add ...` segments
  [[ "$seg" =~ ^git[[:space:]]+add([[:space:]]|$) ]] || continue
  args=" ${seg} "  # pad so ^/$ boundaries become whitespace boundaries
  if [[ "$args" =~ [[:space:]]-A[[:space:]] ]] \
     || [[ "$args" =~ [[:space:]]--all[[:space:]] ]] \
     || [[ "$args" =~ [[:space:]]\.[[:space:]] ]] \
     || [[ "$args" =~ [[:space:]]:/[[:space:]] ]]; then
    ask
  fi
done <<< "$normalized"

exit 0
