---
name: plain-spec
description: Create, maintain, or follow a plain-English written specification (SPEC.md, spec/ files, numbered invariants, tasks, open questions, and a bug log, checked by tests/test_spec_hygiene.py). Use when a repository has SPEC.md or spec/, when the user asks to add a specification, record a bug against an invariant, add or cite an invariant, work the next task, or check spec hygiene. Not cavekit; never use cavekit skills or caveman encoding with it.
---

# Plain-English specification

A written specification states what the code must do as numbered claims, and a test defends each
claim, so that no claim can stop being true without a test failing. In its full form it also holds
the live worklist: tasks in build order, questions that only the maintainer can answer, and the
bugs found, each tied to the claim that would catch it again. It holds no history. The account of
what was measured belongs in `docs/`, and the reason for a change belongs in its commit message.

The system comes from `lcms-feature-map`, which replaced a cavekit specification with it on
2026-09-23 because the compressed encoding was hard for the maintainer to read or edit and saved
fewer tokens than it claimed. It needs no plugin. Do not use the cavekit skills (`/spec`, `/build`,
`/check`, `/backprop`) or caveman encoding in a repository that uses this system.

## When to add one

A specification costs effort in every session: each change of behaviour adds or cites an
invariant, and each bug receives an entry. Recommend one when the project will be developed over
many sessions or by more than one person or agent, and its correctness rests on rules that the
code does not make obvious. Recommend against one for a short-lived or exploratory project, and
for a small library whose rules fit in a short list of non-negotiables in `AGENTS.md`.

- **Full form:** goal, constraints, data model, interfaces, invariants, tasks, open questions,
  and bugs. For pipelines and long-lived applications.
- **Reduced form:** goal, constraints, invariants, and bugs. For a library that has outgrown its
  list of non-negotiables.

## Vocabulary

Each kind of entry has a letter and a number. A number is never reused or changed. Code, tests,
documents, and commit messages cite an entry with a section sign: `§V.20`, `§T.3`, `§B.7`, `§C.4`,
`§D.2`.

| Letter | Kind | Form | Meaning |
|---|---|---|---|
| G | Goal | both | One paragraph stating what the project is for. |
| C | Constraint | both | A fixed decision the code must respect, such as a Python version, a file format, or a scope limit. |
| D | Data model | full | A table, schema, or identifier format. |
| I | Interface | full | A command, protocol, entry point, or file that other code depends on. |
| V | Invariant | both | One statement about behaviour that a test can check. |
| T | Task | full | One unit of work, in build order. |
| O | Open question | full | A decision that only the maintainer can make. |
| B | Bug | both | A defect, its cause, the general rule learned, and the invariant that would catch it again. |

## Files

| File | Holds | Entry heading |
|---|---|---|
| `AGENTS.md` | goal under `## Goal`; constraints under `## Constraints` as `- C<n>: …` bullets | none |
| `SPEC.md` | index: each file below with its id range; at most 6,000 bytes | none |
| `spec/invariants/<area>.md` | invariants, one file per area of the code | `### V<n> — <claim>` |
| `spec/bugs.md` | bug log | `### B<n> — <title>` |
| `spec/data-model.md` (full) | data model | `### D.<n> — <title>` |
| `spec/interfaces.md` (full) | interfaces | `### I.<n> — <title>` |
| `spec/tasks.md` (full) | `## Open` then `## Done`, each in id order | `### T<n> — <title>` |
| `spec/open-questions.md` (full) | open questions, after a "Retired so far — O1, O2." sentence | `### O<n> — <title>` |
| `FORMAT.md` | the entry formats, which the hygiene test parses | none |

The heading separator is a space, an em dash, and a space. An entry the hygiene test cannot parse
is invisible to it, so the formats are rules.

## Entry formats

**Invariant.** One testable claim, with reasoning only where applying the claim needs it, at most
1,200 characters. A final `Test: tests/<file>::<test>` line is recommended; the hygiene test
checks the reverse direction, that some file under `tests/` cites the invariant.

```markdown
### V20 — Retention-time drift within tolerance does not split a consensus feature

Retention-time drift within the configured tolerance still gives one consensus feature; drift
never splits it.

Test: tests/test_linking.py::test_drift_within_tolerance_gives_one_feature
```

**Task** (full form). A status line, a refs line, and one paragraph. A done task keeps only its
claim, its key numbers, and a pointer to the commit or document, in at most 900 characters.

```markdown
### T14 — Group-then-link route

**Status:** to do
**Refs:** D.2,O27

The group-then-link route builds consensus feature groups directly. It cannot start until O27
is answered.
```

**Bug.** One line of fields, then the cause and the general rule, in at most 1,300 characters.
`Caught by` must name at least one existing invariant. The reproduction belongs in the fixing
commit.

```markdown
### B1 — schema_columns returned base-class names as columns

**Date:** 2026-07-30 · **Status:** fixed · **Caught by:** V44

schema_columns read the annotations of every class in the inheritance chain, so it returned
base-class names ahead of the real columns. Rule: derive column lists from the schema's
declared fields, not from class annotations.
```

**Open question** (full form). A heading and one paragraph. An answered question leaves the file,
and its id joins the "Retired so far" sentence.

## Rules for agents

Copy `templates/AGENTS-spec-section.md` into the repository's `AGENTS.md`. Its rules are:

1. Before changing code, read `SPEC.md` and the invariant files that the table in `AGENTS.md`
   names for that code.
2. Full form: take the first task under `## Open` that no open question blocks, and set its
   status to `in progress`.
3. New or changed behaviour adds an invariant or cites an existing one. Cite it in the test's
   docstring, for example `"""L1: drift tolerance (§V.20)."""`.
4. When a test fails or a bug is found: find the cause; identify the invariant whose test would
   have caught it, and if none exists write one with a test that fails on the defective code; add
   a bug entry with status `open`; fix the code; set the status to `fixed`; put the reproduction
   in the commit message and cite `§B.<n>` and `§V.<n>` in its subject.
5. Never answer an open question. Raise it and stop work on any task it blocks. After the
   maintainer answers, move the answer into the contract (C, D, I, or V) or into `docs/`, delete
   the question, and add its id to the "Retired so far" sentence.
6. To finish a task, set it to `done`, move it under `## Done`, shorten it to its claim, numbers,
   and a pointer, and cite `§T.<n>` in the commit subject.
7. Propose specification changes as ordinary edits in the same commit as the code. The maintainer
   decides the wording.
8. Never renumber or reuse an id. Never add history to the specification.
9. Where a document under `docs/` and the specification disagree, the document is wrong.

## Setting one up

1. Ask the maintainer for the goal, the constraints, and any undecided questions, unless
   `AGENTS.md` already states them. Undecided questions become open questions.
2. Copy `templates/FORMAT.md` to the repository root and `templates/test_spec_hygiene.py` to
   `tests/`. Set the constants at the top of the test: `FORM`, `MIN_CONSTRAINTS`, the size limits,
   `MIN_CONTRACT_SHARE` (full form), and the test-level marker if the repository uses one.
3. Write invariants for the behaviour that exists or that the first task delivers. An invariant
   with no test yet goes into `UNTESTED_INVARIANTS` with a reason of more than 40 characters, for
   example "Test arrives with §T.2, which builds the fixture."
4. Full form: write the tasks in build order, beginning with work in progress.
5. Write `SPEC.md`, and add `templates/AGENTS-spec-section.md` to `AGENTS.md`, including the table
   of code areas and their invariant files.
6. Add invariant ids to the docstrings of the tests that already defend them.
7. Run the hygiene test. Then delete one citation and confirm it fails, add a bug whose
   `Caught by` names a missing invariant and confirm it fails, and undo both.

## Converting a cavekit specification

Keep every id. Translate each compressed row into a plain-English entry in the matching file,
with articles and verbs restored. Move §G and §C into `AGENTS.md`. Move narrative found in done
tasks or answered questions to `docs/`, leaving the claim, the numbers, and a pointer. Replace
any `AGENTS.md` instructions that mention `/spec`, `/check`, or `/backprop` with the rules above.
