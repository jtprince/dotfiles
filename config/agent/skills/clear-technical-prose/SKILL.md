---
name: clear-technical-prose
description: Draft, edit, or review durable technical and analytical prose in files, including reports, analyses, READMEs, design documents, PR and issue bodies, and docstrings. Apply automatically to file-bound prose, but not to chat replies, terminal updates, creative writing, legal text, or quoted material.
---

# Clear technical prose

Write for an educated reader who may not share the author's immediate context. Preserve
facts, citations, technical terms, quotations, and the distinction between observation and
judgment. Match an established house style where it conflicts on formatting or terminology.

## Audience and register

- Infer the actual reader, purpose, and genre before drafting. Do not insert that analysis
  into the document.
- Use a formal, objective, direct register. The readers include scientists outside
  software engineering, so avoid colloquialism, industry slang, and figurative flourish.
  State the mechanism instead: "the observed signal is attributable to cytotoxicity rather
  than to receptor engagement", not "a cytotoxicity assay wearing a hat".
- Do not use contractions.
- Open with the claim or outcome when the genre permits it. Do not restate the request,
  add a ceremonial preamble, or close with an offer of further help.
- State facts about the subject, not about the reader: "the three repositories have no
  remote", not "your repositories are not backed up".
- Keep necessary domain vocabulary. Define a term on first use when the intended reader
  may not know it.
- Write headings that name their content: "Decision criteria", not "Go/no-go";
  "Limitations", not "What this cannot tell you".

## Agency and voice

- Name the actor when responsibility, causation, or mechanism matters.
- Use passive or impersonal voice when the actor is unknown or irrelevant, when the
  affected thing is the paragraph's topic, or when a methods description conventionally
  expects it. Do not contort a sentence either to avoid passive voice or to achieve it.
- Use active voice and present tense for any step the reader performs.
- Address the reader only in procedures, runbooks, tutorials, and READMEs. Elsewhere,
  define and state: "the estimand is defined as", not "you should define the estimand".
- Use "we" for analytical decisions, such as a definition, threshold, or choice of method,
  and for work the user directed. Use "I" only when the document must separate the agent's
  judgment from the user's. Do not add a pronoun declaration to a README, PR body, or
  docstring.
- Prefer verbs to nominalizations: "the script fails", not "failure of the script occurs".

## Sentences and coherence

- Keep one idea in each sentence. Split two ideas joined only by a comma and "and". A
  sentence may be long when one idea needs its condition, contrast, or consequence.
- Put established context before new information. Place the sentence's intended emphasis
  near the end.
- Keep the paragraph's topic in subject position when possible. Express its important
  action in the verb.
- Use one term for one concept. If it is a "feature" in the first paragraph, it is not a
  "signal" or a "peak" in the fourth.
- Keep pronouns and modifiers next to the words they govern. Repeat the noun when a pronoun
  could name more than one thing.
- Prefer the short familiar word when it preserves precision: "use", not "utilize";
  "before", not "prior to".
- Limit noun clusters to three words: "the distribution of predicted collision cross
  section values", not "predicted collision cross section value distribution".
- Keep articles and relative pronouns. Do not drop them for compression.
- In procedures, reference documentation, figure legends, and captions, hold procedural
  sentences to about 20 words and descriptive sentences to about 25. Do not apply these
  limits to argument, where qualified sentences carry the precision.
- Use a dash only to set off an appositive definition, not for emphasis, and use few.

## Evidence and uncertainty

- Give every non-obvious quantitative claim a source or reproducible derivation: a file
  path, command, measurement, calculation, or citation. Do not add a redundant citation to
  a value visibly derived from an adjacent table or command output.
- Match the verb to the strength of the evidence, in ascending order:
  1. "may", "can", or "might": possible, not observed.
  2. "appears to": observed, but not committed to.
  3. "suggests": an inference, often about mechanism, from the author's own data.
  4. "indicates": a firm inference from the author's own data.
  5. "demonstrates" or "shows": shown directly in a measurement, table, figure, or output.
- Label claims that sit outside this scale: "expected" for a prediction not yet observed,
  "assumed" for a premise the analysis does not test, and "undetermined" when the evidence
  does not decide the question. Say explicitly what the data cannot decide.
- Do not let a plausible mechanism read as an established one. When a value or assignment
  is curated rather than retrieved from an authoritative source, say so.
- Express an estimate as a bound, a range, or "approximately" with the number. Use one
  qualifier per claim. Do not stack qualifiers or use them to avoid making a claim.
- Audit the work's own weaknesses. State each assumption, say plainly where it fails, give
  the direction of the resulting error, and then state whether the conclusion survives.
  Do not soften this account.
- Give the criterion behind evaluations such as "material", "significant", "unsafe", or
  "preferred".
- Cite by title, venue, year, and DOI or URL. Never invent an author list. When authorship
  is unverified, omit the authors and mark the reference as incomplete.
- Never strengthen, weaken, add, or remove a claim during a style edit.

## Structure by genre

- Reports, recommendations, design decisions, and PR descriptions: conclusion or decision
  first, then evidence, then costs, alternatives, and qualifications.
- Procedures and runbooks: execution order. Put each condition or warning before the action
  it governs, and use one action per numbered step.
- Tutorials: learning order, with an observable result after each substantial step.
- Explanations: conceptual dependency and reader questions. Supply context before conclusions
  that depend on it.
- Proofs and formal arguments: premises before conclusions unless a summary states the result
  first.
- Use a table when readers need to compare repeated fields across several items. Use lists
  for parallel items or sequences. Keep argument in prose.

## Emphasis and metadiscourse

- Carry emphasis through the result, word order, and sentence structure. Bold at most a
  short noun phrase. Do not use italics for tone or exclamation marks for emphasis.
- Delete empty announcements such as "It is worth noting that" and "This section discusses".
  Keep signposting that states scope, dependency, method, or where an argument continues.
- State importance with its criterion: "four wrong headline numbers came from the only region
  with no tests", not "this is the most important issue".

## Patterns to remove

- Remove decorative or generic uses of: delve, tapestry, testament, beacon, landscape,
  realm, journey, navigate, unlock, leverage, robust, seamless, game-changer, paradigm,
  unprecedented, groundbreaking, and cutting-edge. Preserve a literal technical use.
- Remove informal idiom such as "load-bearing", "the crux", "a coin flip", "that bit us",
  "the whole point", "kick off", "wire it up", and "smell test".
- Remove "Importantly," at the head of a sentence, "it's not just X, it's Y", "at the end of
  the day", and "in today's world".
- Remove rhetorical questions from body text. A question may serve as a title only when the
  document exists to answer it.
- Remove reflexive both-sides framing and metaphors that add no precision.
- Do not pad a list to three items. Keep a genuine three-part list when the content has three
  parts.
- Avoid uniform sentence length, repeated paragraph endings, and polished summary sentences
  that merely restate the preceding paragraph.

## Related skills

- Reports, analyses, protocols, and memos also follow `scientific-document-voice`, which adds
  the document skeleton: a labelled summary, numbered sections, captions, citations, and a
  Limitations section.
- Scientific manuscripts and results write-ups also follow `scientific-writing-voice`.
- Within its scope, each of these skills takes precedence over this one where they differ.

## Final pass

Before returning file-bound prose:

1. Cut modifiers that add no factual, logical, or evaluative distinction.
2. Cut repeated claims, empty transitions, and empty metadiscourse.
3. Replace avoidable passive voice and nominalizations without disturbing information flow.
4. Check that each paragraph has a stable topic and moves from context to new information.
5. Check ambiguous pronouns, modifiers, comparisons, and logical connectors.
6. Check that no contraction remains, and that the reader is addressed only in instructional
   genres.
7. Check that each hedge matches the strength of its evidence.
8. Confirm that the edit preserved every fact, number, date, citation, technical term, and
   calibrated qualifier.
