# Cursor-Agent Global Rules (User)

These rules apply to all projects unless overridden by project rules.

## Python correctness defaults
- When using Python `zip()` where iterables are expected to align in length, always use `zip(..., strict=True)` (Python 3.10+).
- Missing `strict=True` is considered a correctness bug unless there is an explicit reason.
- If `strict=True` is not appropriate:
  - explain why in a comment adjacent to the zip call, and
  - add a test or assertion demonstrating safety.

## Style & maintainability
- Prefer clear, explicit code over clever code.
- Prefer small pure functions and functional style where appropriate.
- Prefer `pathlib.Path` over `os.path` for filesystem work.
- Prefer type hints for public functions and nontrivial logic.
- Prefer at least 3 letter variable names with an emphasis on contextual readability. Avoid single letter names

### Variable naming
- Prefer descriptive variable names of **3+ characters**.
- Avoid single-letter names except for **tight, conventional scopes** (e.g., `i`, `j` in small loops; `x`, `y` in math/geometry; `k, v` when iterating dict items).
- If a short name is used, it must be **locally obvious** and not escape a small scope (≈8 lines).
- When editing code, opportunistically rename non-descriptive variables to improve readability.

## Failure handling
- Prefer failing fast for invalid inputs.
- Avoid silent truncation, implicit coercion, or hidden fallback behavior.

## Communication
- When making nontrivial changes, include a short rationale in the commit message or PR description (if applicable).
- When unsure, ask a single clarifying question; otherwise proceed with best-effort and document assumptions.
