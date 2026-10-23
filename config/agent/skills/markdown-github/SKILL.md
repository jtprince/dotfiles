---
name: markdown-github
description: >
  GitHub Flavored Markdown (GFM). Use whenever writing READMEs or other .md files
  rendered on GitHub, issue and PR bodies, PR review comments, release notes,
  or discussion posts.
---

# markdown-github

GFM is CommonMark plus the extensions below.

- Bold / italic / strike: `**bold**`, `*italic*`, `~~strike~~`
- Code block: ```` ```python ```` fences with a language tag
- Table: pipe table with `|---|` separator; `:--:` to align
- Task list: `- [ ] todo`, `- [x] done`
- Alert: `> [!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]` on the first quote line
- Footnote: `text[^1]` and `[^1]: note`
- Collapsible: `<details><summary>Title</summary>` … `</details>` (blank line after `</summary>`)
- Diagram: ```` ```mermaid ```` fence
- Math: `$inline$`, `$$block$$`
- Autolinks: `#123`, `owner/repo#123`, `@user`, commit SHAs, bare URLs
- Relative link: `[text](docs/file.md#heading-anchor)`

Line breaks: in `.md` files a single newline is joined into the paragraph. In
issues, PRs and comments a single newline renders as a line break, so don't
hard-wrap prose there.

Common mistakes:
- Hard-wrapping lines in a PR or issue body.
- Using an alert type other than the five listed (it renders as a plain quote).
- Omitting the blank line before a table or list.
