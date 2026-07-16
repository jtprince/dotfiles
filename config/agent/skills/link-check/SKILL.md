---
name: link-check
description: >
  Validate that links in a file/dir/diff are still good: live (resolves, 200),
  the target actually contains the referenced content (anchor, quote, section),
  and that content supports the surrounding claim. Use when the user says
  "check my links", "verify links", "are these links still valid", "/link-check",
  or before publishing docs/READMEs/PRs.
---

# link-check

Verify links are **valid**, not just alive. Three levels, all required:

1. **LIVE** — URL resolves, returns 200 (follow redirects).
2. **CONTENT** — the page actually contains what was cited: the `#fragment`
   anchor exists, the quoted text is present, the named section/heading is there.
3. **CLAIM** — that content actually *supports the assertion* the link backs in
   the surrounding sentence. A live page that says the opposite is a failure.

Liveness alone is not validity. Always reach level 3.

## Procedure

### 1. Resolve scope
Argument forms:
- `<file>` — check that file.
- `<dir>` — check all `.md` under it.
- `--diff` — check only links added/changed in the current git diff
  (`git diff` / `git diff --staged`).
- no arg — the file currently in focus.

Extract every link with its **surrounding claim** (the sentence/clause it sits
in) and any `#fragment`. Catch markdown `[text](url)`, reference-style
`[text][ref]` + `[ref]: url`, and bare URLs. Dedupe repeated URLs (verify once,
report each occurrence).

### 2. Liveness triage (bulk markdown only)
For a directory of markdown, optionally fast-pass with the repo script:

```
markdown-check-for-broken-links <dir>
```

It is **triage, not verdict**: HEAD-only (false-negatives on servers that block
HEAD), markdown links only, no content/claim check. Use it to narrow a big tree,
then verify survivors at level 2–3 below. Skip it for single files / small sets.

### 3. Per-link verification (core)
`WebFetch` each unique URL. For each, decide:
- **live**: ✅ 200 / ⚠️ redirect-to-different-content / ❌ dead/404/timeout.
- **content**: ✅ cited fragment/quote/section present / ⚠️ moved or paraphrased
  / ❌ absent. For `#fragment`, confirm an anchor/heading with that id exists.
- **claim**: ✅ supports / ⚠️ partial or tangential / ❌ contradicts or unrelated.

Caps & skips:
- Limit concurrent fetches (~5) to stay polite.
- Auth/login-walled, paywalled, or `localhost` URLs → mark `skipped` with reason,
  don't guess.
- `mailto:` / local-file links → existence check only (no claim).

### 4. Report
One table per file, then a summary line:

```
status | url | live | content | claim | note
```

- `status`: ✅ valid · ⚠️ needs-attention · ❌ broken · ⏭ skipped.
- For every ⚠️/❌, give a concrete fix: corrected URL, updated `#anchor`, a
  Wayback fallback (`https://web.archive.org/web/<url>`) for dead-but-cited
  pages, or "claim unsupported — revise text to match source."
- Summary: `N links · X valid · Y attention · Z broken · W skipped`.

Do not edit files unless the user asks — report and propose. If they say "fix
them," apply the suggested URL/anchor fixes; never silently rewrite a claim,
flag it for the user instead.

## Example

Input line:
`Rust's ownership model [eliminates data races](https://doc.rust-lang.org/book/ch16-00-concurrency.html#fearless).`

- live ✅ (200), content ⚠️ (`#fearless` anchor not found on that page),
  claim ✅ (page does cover concurrency safety).
- Fix: anchor missing → drop `#fearless` or point to the actual section id.
