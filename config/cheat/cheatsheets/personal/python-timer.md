# With a single pip install

pip install linetimer

```
from linetimer import CodeTimer
with CodeTimer('name of block'):
    ...
    ...
```


# Lightweight solution

```
from time import perf_counter
_start = perf_counter()

<your code>

print(f">>> ELAPSED TIME:  {perf_counter() - _start:.2f}")
```
