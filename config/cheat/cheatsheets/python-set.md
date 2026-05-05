```python
# union — all items from both
set1 | set2
set1.union(set2)

# intersection — items in both
set1 & set2
set1.intersection(set2)

# difference — in set1, not in set2
set1 - set2
set1.difference(set2)

# symmetric difference — in one but not both
set1 ^ set2
set1.symmetric_difference(set2)

# subset — set1 inside set2
set1 <= set2
set1.issubset(set2)

# proper subset — subset and not equal
set1 < set2

# superset — set2 inside set1
set1 >= set2
set1.issuperset(set2)

# disjoint — no items in common
set1.isdisjoint(set2)
```

