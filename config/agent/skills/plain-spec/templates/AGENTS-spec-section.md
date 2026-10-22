## The spec

`SPEC.md` is the index to this project's contract; the contract itself is plain English in
`spec/`, split by topic and edited by hand (format: `FORMAT.md`). Cite ids as `§V.14`, `§T.7`,
`§B.3`, `§C.2` in code comments, test docstrings, docs, and commit subjects. Do not use the cavekit
skills (`/spec`, `/build`, `/check`, `/backprop`) or caveman encoding here.

Read what the task touches:

| before changing | read |
|---|---|
| `<package>/<area>/` | `spec/invariants/<area>.md` |
| choosing what to work on | `spec/tasks.md` (open first), `spec/open-questions.md` |

Rules:

1. **Invariants are testable claims.** New or changed behaviour adds an invariant or cites an
   existing one, and a test cites it in its docstring, for example `"""L1: drift tolerance
   (§V.20)."""`.
2. **Every bug names the invariant that catches it again.** When a test fails or a bug is found:
   find the cause; identify the invariant whose test would have caught it, and if none exists,
   write one with a test that fails on the defective code; add an entry to `spec/bugs.md` with
   status `open`; fix the code; set the status to `fixed`; put the reproduction in the commit
   message and cite `§B.<n>` and `§V.<n>` in its subject.
3. **Open questions are not yours to resolve.** Raise them and stop work on any task they block.
   After the maintainer answers, move the answer into the contract or `docs/`, delete the
   question, and add its id to the "Retired so far" sentence.
4. **Tasks are the build order.** Take the first open task that no open question blocks and keep
   its **Status** line current. A done task moves under `## Done` and shrinks to its claim, its
   numbers, and a pointer; cite `§T.<n>` in the closing commit.
5. **The maintainer owns the wording.** Propose spec changes as ordinary edits in the same commit
   as the code.
6. **The spec does not carry its own history.** Narrative goes in `docs/`, reasons in commit
   messages (`git log --grep '§T.12'`). Ids are never reused or renumbered.
7. Where a document under `docs/` and the spec disagree, the document is wrong.

`tests/test_spec_hygiene.py` enforces the format: every invariant cited by a test, every bug naming
an invariant, ids defined once, and size limits.
