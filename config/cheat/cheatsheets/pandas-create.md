```python

# Dict of lists
df = pd.DataFrame({"a": [1, 2], "b": [3, 4]})

# List of dicts
df = pd.DataFrame([{"a": 1, "b": 3}, {"a": 2, "b": 4}])

# List of lists + columns
df = pd.DataFrame([[1, 3], [2, 4]], columns=["a", "b"])

## Numpy and Series

# NumPy 2D array
df = pd.DataFrame(np.array([[1, 2], [3, 4]]), columns=["x", "y"])

# NumPy structured / recarray
df = pd.DataFrame(np.rec.array([(1, 2), (3, 4)], names=["x", "y"]))

# Dict of Series
df = pd.DataFrame({"a": pd.Series([1, 2]), "b": pd.Series([3, 4])})


## Files
# (obviously from csv and parquet)

# JSON
df = pd.read_json("file.json")

# SQL query
df = pd.read_sql("SELECT * FROM my_table", conn)


## EMPTY

# Empty DataFrame
df = pd.DataFrame()

# Columns only
df = pd.DataFrame(columns=["a", "b"])

# Index + columns only
df = pd.DataFrame(index=range(3), columns=["a", "b"])
```
