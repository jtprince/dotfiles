# Global directives

## Git write policy

Do **not** run `git commit`, `git push`, or outward publishing (`gh pr create`,
`gh pr merge`, `gh release create`) unless the user has **explicitly approved
that specific action**—for example, an approved plan step that names it or a
direct instruction such as "commit this", "push it", or "open the PR". General
approval to work on a task is not approval to commit or publish.

- Staging explicit paths, `git diff`, `git status`, `git log`, branching, and
  reading history are allowed without asking.
- When work is ready, stop and propose commit, push, or PR creation as an
  explicit next step.
- This policy also applies to aliases and environment-prefixed forms that
  literal command rules might not catch.

## Git staging

Stage explicit paths with `git add <file> ...`. Never use `git add -A`,
`git add --all`, `git add .`, or `git add :/`; blanket staging can sweep in
untracked files. `git add -u`, `git add -p`, and explicit paths are allowed.
