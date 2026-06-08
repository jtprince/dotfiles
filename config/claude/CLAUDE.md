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
  let the user decide. A `permissions.ask` rule in `settings.json` also enforces this —
  treat its confirmation prompt as expected, not an error to work around.
- This applies to aliases and env-prefixed forms too (e.g. `gc`, `GIT_EDITOR=… git commit`),
  which the literal permission rules may not catch — don't use them to commit/push around
  the gate.

## Git staging

Stage **explicit paths** (`git add <file> …`). Never `git add -A` / `--all` / `.` / `:/` —
blanket staging sweeps in untracked files. (A PreToolUse hook guards this and will prompt.)
