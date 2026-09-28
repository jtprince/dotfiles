---
name: markdown-discord
description: >
  Discord message formatting ("Discord markdown"). Use whenever writing text the
  user will paste into a Discord channel, thread, DM, or forum post, or send
  through a Discord bot or webhook.
---

# markdown-discord

- Bold: `**bold**`
- Italic: `*italic*` or `_italic_`
- Underline: `__underline__`
- Strikethrough: `~~strike~~`
- Spoiler: `||spoiler||`
- Inline code: `` `code` ``
- Code block: ```` ```python ```` fences; language tag gives highlighting
- Link: `[text](url)` (masked link); `<url>` suppresses the embed
- Bullets: `- item` or `* item`, indent for sub-bullets
- Numbered list: `1. item`
- Quote: `> line`, or `>>> ` to quote everything after it
- Heading: `#`, `##`, `###` only
- Subtext: `-# small grey text`
- Mention: `<@user_id>`, `<#channel_id>`, `<@&role_id>`

Not supported: tables (use a code block), images inline, horizontal rules,
headings below `###`.

Common mistakes:
- Using `__text__` for bold (it underlines).
- Building a pipe table.
- Forgetting the 2000-character message limit (4000 with Nitro).
