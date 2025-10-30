

# Add a markdown header

`call InsertKnowledgeRepoHeader()`

# Template for Notebook Raw Header:
```
---
title: "Some Title Here"
authors:
- John T. Prince
tags:
- some_tag
created_at: <date>
tldr: "<SOME TLDR>"
---
```

# Add to the repo

```bash
knowledge_repo add MatchTop20flourophore.ipynb \
    -p jtprince/one_shot/quality_scores_for_first_flourophore_experiment
```

That will create this kind of tree and a local git branch:
`jtprince/one_shot/quality_scores_for_first_flourophore_experiment.kp`

```text
jtprince
└── one_shot
    └── quality_scores_for_first_flourophore_experiment.kp
        ├── images
        │   ├── distinct-signal.png
        │   ├── rhodamine-cyclization.png
        │   └── shelf-signal.png
        ├── knowledge.md
        ├── REVISION
        ├── src
        │   └── MatchTop20flourophore.ipynb
        └── UUID
```

Images are slurped into the repo automatically.

```bash
cd $KNOWLEDGE_REPO
git push

# Then go to the branch, open a PR, merge it and delete branch.
```


# Update a post

Alter the src document (in this case
`jtprince/one_shot/quality_scores_for_first_flourophore_experiment/src/MatchTop20flourophore.ipynb`
or a copy, and then add the `--update` flag:

```bash
knowledge_repo add MatchTop20flourophore.ipynb \
    -p jtprince/one_shot/quality_scores_for_first_flourophore_experiment \
    --update
```

```bash
cd $KNOWLEDGE_REPO
git push

# Then go to the branch, open a PR, merge it and delete branch.
```

# Delete a post

Create a branch and delete the directory that needs deleting and make a PR for
it.
