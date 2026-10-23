---
name: markdown-obsidian
description: >
  Obsidian note formatting ("Obsidian markdown"). Use whenever writing or editing
  notes in an Obsidian vault, or text the user will paste into Obsidian:
  wikilinks, embeds, callouts, tags, properties.
---

# markdown-obsidian

Obsidian is CommonMark plus GFM (tables, task lists, strikethrough, footnotes)
plus the extensions below.

- Internal link: `[[Note]]`, `[[Note|alias]]`
- Link to heading / block: `[[Note#Heading]]`, `[[Note#^block-id]]`
- Block ID: end a paragraph with ` ^block-id`
- Embed: `![[Note]]`, `![[Note#Heading]]`, `![[image.png|300]]`
- Callout: `> [!note] Title` then `> body`; `[!tip]`, `[!warning]`, etc.
- Foldable callout: `> [!note]-` (collapsed) or `> [!note]+` (expanded)
- Highlight: `==text==`
- Comment (hidden): `%%comment%%`
- Tag: `#tag`, `#nested/tag` (no spaces)
- Properties: YAML frontmatter between `---` lines at the top of the file
- Math: `$inline$`, `$$block$$`
- Diagram: ```` ```mermaid ```` fence
- Footnote: `text[^1]` and `[^1]: note`, or inline `^[note]`

Line breaks: by default a single newline renders as a line break ("Strict line
breaks" off). Don't hard-wrap prose.

Common mistakes:
- Writing `[text](Note.md)` when the vault uses wikilinks. Match the vault.
- Putting a pipe inside a wikilink alias within a table without escaping it (`\|`).
- A tag that is all digits (`#2026` is not a tag).
