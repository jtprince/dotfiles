---
name: markdown-reddit
description: >
  Reddit post and comment formatting ("Reddit markdown" or "reddit flavored
  markdown"). Use whenever writing text the user will paste into a Reddit post,
  comment, or reply, or a file meant for Reddit.
---

# markdown-reddit

Reddit uses a CommonMark-like flavor with a few extensions. Target both new and
old Reddit.

- Bold: `**bold**`
- Italic: `*italic*`
- Strikethrough: `~~strike~~`
- Superscript: `^word` or `^(several words)`
- Spoiler: `>!spoiler!<`
- Inline code: `` `code` ``
- Code block: indent every line 4 spaces (fences don't render on old Reddit)
- Link: `[text](url)`, or `r/sub`, `u/user`
- Bullets: `* item` or `- item`
- Numbered list: `1. item`
- Quote: `> text`
- Heading: `# H1` through `###### H6`
- Table: GFM pipe table with a `|---|` separator row
- Horizontal rule: `***`

Line breaks: a single newline does not break the line. Use a blank line for a
new paragraph, or end the line with two spaces for a line break.

Common mistakes:
- Starting a list or table directly under a paragraph. Put a blank line before it.
- Using fenced code blocks when the audience may be on old Reddit.
- Writing `^two words` (only the first word is superscripted).
