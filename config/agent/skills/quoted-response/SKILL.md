---
name: quoted-response
description: >
  Reply to someone's message by block-quoting each part being answered and
  answering directly beneath it, one point at a time. Use when drafting a reply
  the user will send to another person (Slack thread, email, PR or issue
  comment, code review, Reddit or Discord reply, forum post), when replying in
  chat to a user message that asks several questions or raises several points,
  or when the user asks for a quoted, inline, or point-by-point reply.
---

# Quoted response

The author of a message knows what they wrote and wants to see the answer to
each part of it. A reply that answers in a separate block of prose forces the
author to match each answer to its question. Quote the part being answered,
then answer it directly beneath the quote.

## Pattern

Original message:

```text
I'b Bob. I have a question about xyz: Why did you do xyz like that?
```

Reply:

```markdown
> ... Why did you do xyz like that?

I did it that way because the upstream API returns results unsorted.
```

## Prose of the answers

Write each answer by the `clear-technical-prose` skill, limited to these
sections:

- Audience and register: formal, direct, and free of colloquialism and
  figurative flourish. No contractions, no restatement of the question, no
  ceremonial opening, and no closing offer of further help.
- Sentences and coherence.
- Evidence and uncertainty: sources for non-obvious claims, and verbs matched
  to the strength of the evidence.
- Emphasis and metadiscourse.
- Patterns to remove.
- Final pass, items 1 through 5, 7, and 8.

Do not apply these parts, because the quote-and-answer form replaces them or
a reply makes them inapplicable:

- Structure by genre. The quoted points set the order. Within an answer, give
  the direct answer first and the reasoning after it.
- The rule to address the reader only in instructional genres, and final-pass
  item 6. A reply addresses its recipient as "you", and the sender writes as
  "I" or "we".
- Rules about headings, captions, tables of results, and document skeletons,
  including the related `scientific-document-voice` skill.

When the reply goes to the user in chat, the chat communication rules in the
system prompt take precedence over `clear-technical-prose` where they differ.

## Rules

1. Quote only the words being answered. Omit greetings, sign-offs, and
   context that needs no response.
2. Use an ellipsis (`...`) to mark omitted text at the start, middle, or end
   of a quote, or to join two separated phrases that form one point.
3. Quote verbatim. Do not correct spelling, grammar, or capitalization inside
   a quote. Put any clarifying insertion in square brackets:
   `> ... the [staging] job failed ...`.
4. Do not let an ellipsis change the meaning of what the author wrote.
5. Answer one point per quote. When a message asks three questions, the reply
   has three quote-and-answer pairs.
6. Follow the order of the original message unless one answer depends on
   another.
7. Requote freely. The same phrase may appear in more than one quote when it
   bears on more than one answer.
8. Place the answer immediately after its quote. Do not collect answers at
   the end.
9. Do not drop a question. When the answer is unknown, quote the question and
   say so.
10. Put general remarks that answer no specific passage (a thank-you, a
    summary, a next step) after the last pair, without a quote.
11. When a message is a single short question in a live conversation, and
    the answer follows it directly, the quote may be omitted.

## Nested quotes

When the reply answers a reply, and the quoted text does not make sense
without the message it answered, include the earlier layer as a nested quote
above it:

```markdown
>> Can we drop Python 3.9 support?
>
> ... only if the cluster images are upgraded first.

The cluster images were upgraded last week, so 3.9 can go.
```

Include an earlier layer only when it supplies needed context. Most replies
need one level.

In a thread with several participants, name the speaker at the start of the
quote when the source is ambiguous: `> **Alice:** ... only if the cluster
images are upgraded first.`

## Markdown mechanics

These rules hold in CommonMark, GitHub, Reddit, and Obsidian.

- Start each quoted line with `> `. Start each nested line with `>> `.
- Leave a blank line between a quote and the answer. Without it, the answer
  line continues the quote (lazy continuation).
- Keep a multi-paragraph quote in one block by putting `>` alone on the blank
  line between its paragraphs.
- Separate a nested layer from the outer layer with a line containing only
  `>`.

Platform differences (apply the matching `markdown-*` skill for other syntax):

| Platform | Quote | Nested quote | Note |
| --- | --- | --- | --- |
| CommonMark, GitHub, Obsidian | `> ` | `>> ` | GitHub "Quote reply" produces the same form. |
| Reddit | `> ` | `>> ` | A blank line after the quote is required. |
| Slack | `> ` | Not supported | Name the earlier speaker inside a single-level quote: `> Alice wrote: ...`. |
| Discord | `> ` per line | Not supported | Do not use `>>>`. It quotes the rest of the message, including the answer. |
| Plain-text email | `> ` | `>> ` | Matches the conventional reply quoting of mail clients. |
