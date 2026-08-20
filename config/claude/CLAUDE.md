# Global directives

## Git write policy

Do **not** run `git commit`, `git push`, or outward publishing (`gh pr create`,
`gh pr merge`, `gh release create`) unless the user has **explicitly approved that
specific action** — e.g. an approved plan step that names it, or a direct instruction
("commit this", "push it", "open the PR"). General approval to work on a task is **not**
approval to commit or push.

- Staging explicit paths, `git diff`, `git status`, `git log`, branching, and reading
  history are fine without asking.
- When the work is ready, **stop and propose** commit / push / PR as an explicit step and
  let the user decide.
- This applies to aliases and env-prefixed forms too (e.g. `gc`, `GIT_EDITOR=… git commit`) —
  don't use them to commit/push around the gate.

### Bypass-mode carve-out

When a system reminder says **bypass permissions mode is active** (session started with
`--dangerously-skip-permissions`), that mode is an explicit *"don't stop and ask me"*
contract — usually an unattended overnight run, where stopping to propose a commit wastes
the whole run. In that mode only:

- `git commit` is **pre-approved**. Commit finished work as you go; don't stop and propose it.
  Still branch first if you're on the default branch, and still stage explicit paths.
- `git push`, `gh pr create`, `gh pr merge`, `gh release create`, and anything else that
  leaves the machine remain **fully gated** — outward publishing is not covered by this
  carve-out. If you reach that point unattended, stop, leave the commits on the branch, and
  say what's ready to push.
- Everything above about *how* to commit still holds: no blanket staging, and the commit
  message trailer requirement is unchanged.

Outside bypass mode, the default policy above applies in full.

## Git staging

Stage **explicit paths** (`git add <file> …`). Never `git add -A` / `--all` / `.` / `:/` —
blanket staging sweeps in untracked files. (A PreToolUse hook guards this and will prompt —
except in bypass permissions mode, where it stays silent, so the rule is on you.)

@RTK.md
