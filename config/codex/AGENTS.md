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

## Slack-formatted Markdown

- When producing Slack-flavored Markdown, format links as standard Markdown:
  `[descriptive English text](URL)`.
- Never use angle-bracket link syntax such as `<URL>` or `<URL|label>`.
- Use a bare URL only when displaying the URL itself is useful.

## Git write policy

Do **not** run `git commit`, `git push`, or outward publishing (`gh pr create`,
`gh pr merge`, `gh release create`) unless the user has **explicitly approved
that specific action**—for example, an approved plan step that names it or a
direct instruction such as "commit this", "push it", or "open the PR". General
approval to work on a task is not approval to commit or publish.

- Staging explicit paths, `git diff`, `git status`, `git log`, branching, and
  reading history are allowed without asking.
- When work is ready, stop and propose commit, push, or PR creation as an
  explicit next step.
- This policy also applies to aliases and environment-prefixed forms that
  literal command rules might not catch.

## Git staging

Stage explicit paths with `git add <file> ...`. Never use `git add -A`,
`git add --all`, `git add .`, or `git add :/`; blanket staging can sweep in
untracked files. `git add -u`, `git add -p`, and explicit paths are allowed.
