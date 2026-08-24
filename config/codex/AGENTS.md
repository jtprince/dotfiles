# Global directives

## Writing style

For durable prose written into files, apply the `clear-technical-prose` skill. This rule
does not govern chat or terminal updates.

Preserve facts, citations, technical terms, quotations, and calibrated uncertainty. Prefer
concrete subjects, active verbs, consistent terminology, and the shortest wording that
preserves meaning. Follow the target repository's established conventions when they
conflict on formatting or terminology.

## Slack-formatted Markdown

- When producing Slack-flavored Markdown, format links as standard Markdown:
  `[descriptive English text](URL)`.
- Never use angle-bracket link syntax such as `<URL>` or `<URL|label>`.
- Use a bare URL only when displaying the URL itself is useful.

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
