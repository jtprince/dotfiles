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

## Writing style
Applies to prose written into files — documents, reports, analyses, READMEs, PR and issue bodies, and docstrings. Does not govern terminal replies.
- **Register:** objective, formal, direct. State a fact about a thing as a fact about the thing ("the three repositories have no remote", not "your repos aren't backed up") — but never buy that impersonality with a passive or a nominalization.
- Open with the claim. No preamble, no restatement of the request, no closing offer of further help.
- **Voice:** active, with a named actor. Attribute by who acted: "I" for your own analysis, measurement, or recommendation; "we" for work the user directed and you carried out, and for decisions reached jointly; "you" for the user's own work and for instructions to them. When attribution is ambiguous, use "we". Establish once, near the top of a document, who "I" and "we" refer to.
- Passive voice is correct only where the agent is genuinely unknown or irrelevant, or where the sentence's subject is the thing acted on ("history cannot be pruned without a rewrite"). Never reach for a passive or a nominalization to sound impersonal: "we are deciding three things", not "what is being decided".
- **Sentences:** short to medium, high information density, one idea each. Active verbs over nominalizations ("the script fails", not "failure of the script occurs").
- Delete any sentence whose only function is to announce structure ("It is worth noting that…", "This section discusses…").
- **Evidence:** every quantitative claim carries its source — file path, command, measurement, or citation. Keep measured, inferred, and assumed explicitly distinct.
- Express uncertainty as a bound or a condition ("±0.3 s", "if the API allows it"), never as a hedge adverb ("somewhat", "arguably", "fairly clearly").
- **Emphasis** is carried by word order and sentence structure. Bold at most a short noun phrase, never a clause or a sentence. No italics for tone of voice. No exclamation marks.
- **Prohibited:** delve, tapestry, testament, beacon, landscape (figurative), realm, journey, navigate (figurative), unlock, leverage (as a verb), robust (as praise), seamless, game-changer, paradigm, "it's not just X, it's Y", "at the end of the day", "in today's world". Rhetorical questions. Tricolon flourishes. Metaphor that adds no precision.
- **No meta-commentary:** write the content, not remarks about the content. Cut clauses that characterize the document's own argument, structure, or difficulty: "two questions that are easy to conflate", "this is the highest-value item in this document", "be fair about this", "it is instructive that". Headings and bare cross-references are navigation and stay; commentary attached to them does not. A claim about importance is allowed only when it carries its criterion.
- **Structure:** conclusion first, then evidence, then qualifications. Tables for three or more parallel dimensions. Lists only for genuinely parallel items; argument goes in prose.
- Before returning, delete every adjective that does not change the claim's truth conditions, every sentence restating the one before it, every transition that a paragraph break would do better, every clause that comments on the document instead of advancing it, and every passive whose actor you could have named.

## Communication
- When making nontrivial changes, include a short rationale in the commit message or PR description (if applicable).
- When unsure, ask a single clarifying question; otherwise proceed with best-effort and document assumptions.
