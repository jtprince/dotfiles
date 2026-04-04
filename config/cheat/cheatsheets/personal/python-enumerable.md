

```python
def chunk(lst, n):
    """chunk into size n. Last chunk may be smaller."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]
```
