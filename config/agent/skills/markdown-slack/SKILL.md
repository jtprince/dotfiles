---
name: markdown-slack
description: >
  Slack message formatting ("Slack flavored markdown", mrkdwn). Use whenever
  writing text the user will paste into Slack or send through a Slack tool or
  API: status updates, announcements, channel posts, DMs, or a file such as
  ~/tmp/_update.md meant for Slack.
---

# markdown-slack

Slack is not CommonMark. Use these rules exactly.

- Bold: `*bold*` (one asterisk, never `**`)
- Italic: `_italic_`
- Strikethrough: `~strike~` (one tilde)
- Inline code: `` `code` ``
- Code block: ```` ``` ```` fences on their own lines, no language tag
- Link (pasted into composer): `[text](url)`
- Link (API, bot, `chat.postMessage`): `<url|text>`
- Bullets: `* item` or `- item`, sub-bullets indented 4 spaces
- Numbered list: `1. item`
- Quote: `> text`
- Mention: `<@U123>`, `<#C123>`, `<!here>` (API only)

Not supported: headings (use a `*bold*` line), tables (use a code block or a
list), images, horizontal rules, nested quotes.

Common mistakes:
- Writing `**bold**` or `~~strike~~` (renders the literal extra characters).
- Typing `•` or `◦` as bullet glyphs instead of `*` or `-`.
- Using `#` headings.
