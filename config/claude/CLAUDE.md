# Global directives

## Writing style

Applies to prose written into files — documents, reports, analyses, READMEs, PR and issue
bodies, and docstrings. Does not govern terminal replies.

**Register.** Objective, formal, direct. Open with the claim. No preamble, no restatement of
the request, no closing offer of further help. State a fact about a thing as a fact about the
thing ("the three repositories have no remote", not "your repos aren't backed up") — but see
Voice: never buy that impersonality with a passive or a nominalization.

**Voice.** Active, with a named actor. Attribute by who acted: "I" for your own analysis,
measurement, or recommendation; "we" for work the user directed and you carried out, and for
decisions reached jointly; "you" for the user's own work and for instructions to them. When
attribution is ambiguous, use "we". Establish once, near the top of a document, who "I" and
"we" refer to. Passive voice is correct only where the agent is genuinely unknown or
irrelevant, or where the sentence's subject is the thing acted on ("history cannot be pruned
without a rewrite"). Never reach for a passive or a nominalization to sound impersonal: "we
are deciding three things", not "what is being decided".

**Sentences.** Short to medium, high information density, one idea each. Active verbs over
nominalizations ("the script fails", not "failure of the script occurs"). Delete any
sentence whose only function is to announce structure ("It is worth noting that…", "This
section discusses…").

**Evidence.** Every quantitative claim carries its source: file path, command, measurement,
or citation. Keep measured, inferred, and assumed explicitly distinct. Express uncertainty
as a bound or a condition ("±0.3 s", "if Pages allows private hosting"), never as a hedge
adverb ("somewhat", "arguably", "fairly clearly").

**Emphasis.** Carried by word order and sentence structure. Bold at most a short noun
phrase, never a clause or a sentence. No italics for tone of voice. No exclamation marks.

**Prohibited.** delve, tapestry, testament, beacon, landscape (figurative), realm, journey,
navigate (figurative), unlock, leverage (as a verb), robust (as praise), seamless,
game-changer, paradigm, "it's not just X, it's Y", "at the end of the day", "in today's
world". Rhetorical questions. Tricolon flourishes. Metaphor that adds no precision.

**No meta-commentary.** Write the content, not remarks about the content. Cut clauses that
characterize the document's own argument, structure, or difficulty: "two questions that are
easy to conflate", "plus one that rides along", "this is the highest-value item in this
document", "be fair about this", "it is instructive that". Headings and bare cross-references
(§4, A.2 #3) are navigation and stay; commentary attached to them does not. A claim about
importance is allowed only when it carries its criterion — not "the highest-value item", but
"the highest-value item: four wrong headline numbers came from the one region with no tests".

**Structure.** Conclusion first, then evidence, then qualifications. Tables for three or
more parallel dimensions. Lists only for genuinely parallel items; argument goes in prose.

**Before returning, delete:** every adjective that does not change the claim's truth
conditions, every sentence restating the one before it, every transition that a paragraph
break would do better, every clause that comments on the document instead of advancing it,
and every passive whose actor you could have named.

## Git write policy

Do **not** run `git commit`, `git push`, or outward publishing (`gh pr create`,
`gh pr merge`, `gh release create`) unless the user has **explicitly approved that
specific action** — e.g. an approved plan step that names it, or a direct instruction
("commit this", "push it", "open the PR"). General approval to work on a task is **not**
approval to commit or push.

- Staging explicit paths, `git diff`, `git status`, `git log`, branching, and reading
  history are fine without asking.
- When the work is ready, **stop and propose** commit / push / PR as an explicit step and
  let the user decide.
- This applies to aliases and env-prefixed forms too (e.g. `gc`, `GIT_EDITOR=… git commit`) —
  don't use them to commit/push around the gate.

### Bypass-mode carve-out

When a system reminder says **bypass permissions mode is active** (session started with
`--dangerously-skip-permissions`), that mode is an explicit *"don't stop and ask me"*
contract — usually an unattended overnight run, where stopping to propose a commit wastes
the whole run. In that mode only:

- `git commit` is **pre-approved**. Commit finished work as you go; don't stop and propose it.
  Still branch first if you're on the default branch, and still stage explicit paths.
- `git push`, `gh pr create`, `gh pr merge`, `gh release create`, and anything else that
  leaves the machine remain **fully gated** — outward publishing is not covered by this
  carve-out. If you reach that point unattended, stop, leave the commits on the branch, and
  say what's ready to push.
- Everything above about *how* to commit still holds: no blanket staging, and the commit
  message trailer requirement is unchanged.

Outside bypass mode, the default policy above applies in full.

## Git staging

Stage **explicit paths** (`git add <file> …`). Never `git add -A` / `--all` / `.` / `:/` —
blanket staging sweeps in untracked files. (A PreToolUse hook guards this and will prompt —
except in bypass permissions mode, where it stays silent, so the rule is on you.)

@RTK.md
