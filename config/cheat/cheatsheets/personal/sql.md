SQL is implemented as if a query was executed in the following order:

1. FROM clause
2. WHERE clause
3. GROUP BY clause
4. HAVING clause
5. SELECT clause
6. ORDER BY clause

For most relational database systems, this order explains which names (columns
or aliases) are valid because they must have been introduced in a previous
step.
