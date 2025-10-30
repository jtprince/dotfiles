

[[inner for inner in range(2)] for outer in range(3)]
# -> [[0, 1], [0, 1], [0, 1]]

[[(outer, inner) for inner in range(2)] for outer in range(3)]
# -> [[(0, 0), (0, 1)], [(1, 0), (1, 1)], [(2, 0), (2, 1)]]


