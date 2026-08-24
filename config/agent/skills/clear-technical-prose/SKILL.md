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
- Use an objective, formal, direct register. Open with the claim or outcome when the genre
  permits it. Do not restate the request, add a ceremonial preamble, or close with an offer
  of further help.
- State facts about the subject, not about the reader: "the three repositories have no
  remote", not "your repositories are not backed up".
- Keep necessary domain vocabulary. Define a term when the intended reader may not know it.

## Agency and voice

- Prefer active voice and name the actor when responsibility, causation, or mechanism
  matters.
- Use passive voice when the actor is unknown or irrelevant, when the affected thing is the
  paragraph's topic, or when passive voice preserves the established-to-new information
  flow.
- Use "I" for the agent's own analysis, measurement, or recommendation; "we" for work the
  user directed and the agent carried out, or for a decision reached jointly; and "you" for
  the user's work and for instructions. In a long analysis, establish these meanings once
  if ambiguity is likely. Do not add a pronoun declaration to a README, PR body, or docstring.
- Prefer verbs to nominalizations: "the script fails", not "failure of the script occurs".

## Sentences and coherence

- Keep one idea in each sentence. A sentence may be long when one idea needs its condition,
  contrast, or consequence.
- Put established context before new information. Place the sentence's intended emphasis
  near the end.
- Keep the paragraph's topic in subject position when possible. Express its important
  action in the verb.
- Use one term for one concept. Repeat the term instead of rotating synonyms.
- Keep pronouns and modifiers next to the words they govern. Repeat the noun when a pronoun
  could name more than one thing.
- Prefer the short familiar word when it preserves precision. A longer word earns its place
  by expressing a distinction the shorter word lacks.

## Evidence and uncertainty

- Give every non-obvious quantitative claim a source or reproducible derivation: a file
  path, command, measurement, calculation, or citation. Do not add a redundant citation to
  a value visibly derived from an adjacent table or command output.
- Distinguish measured, derived, inferred, assumed, and estimated claims in language suited
  to the document.
- Express uncertainty as a bound or condition when the evidence permits it. Otherwise use
  one calibrated qualifier, such as "likely", "generally", or "approximately". Do not stack
  qualifiers or use them to avoid making a claim.
- Give the criterion behind evaluations such as "material", "significant", "unsafe", or
  "preferred".
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

- Carry emphasis through word order and sentence structure. Bold at most a short noun phrase.
  Do not use italics for tone or exclamation marks for emphasis.
- Delete empty announcements such as "It is worth noting that" and "This section discusses".
  Keep signposting that states scope, dependency, method, or where an argument continues.
- State importance with its criterion: "four wrong headline numbers came from the only region
  with no tests", not "this is the most important issue".

## Patterns to remove

- Remove decorative or generic uses of: delve, tapestry, testament, beacon, landscape,
  realm, journey, navigate, unlock, leverage, robust, seamless, game-changer, and paradigm.
  Preserve a literal or load-bearing technical use.
- Remove "it's not just X, it's Y", "at the end of the day", "in today's world", rhetorical
  questions used as scaffolding, padded three-part lists, reflexive both-sides framing, and
  metaphors that add no precision.
- Do not pad a list to three items. Keep a genuine three-part list when the content has three
  parts.
- Avoid uniform sentence length, repeated paragraph endings, and polished summary sentences
  that merely restate the preceding paragraph.

## Final pass

Before returning file-bound prose:

1. Cut modifiers that add no factual, logical, or evaluative distinction.
2. Cut repeated claims, empty transitions, and empty metadiscourse.
3. Replace avoidable passive voice and nominalizations without disturbing information flow.
4. Check that each paragraph has a stable topic and moves from context to new information.
5. Check ambiguous pronouns, modifiers, comparisons, and logical connectors.
6. Confirm that the edit preserved every fact, number, date, citation, technical term, and
   calibrated qualifier.
