

# use line profiler
pip install line_profiler

## Ipython
# assuming a function `convert_units`

[1]: %load_ext line_profiler
[2]: %lprun -f convert_units convert_units(arg1, arg2, ...)

# use memory profiler
pip install memory_profiler

# Note that memory profiler must pull funcs from a real *file*
[1]: from unit_conversion import convert_units
[2]: %load_ext memory_profiler
[3]: %mprun -f convert_units convert_units(arg1, arg2, ...)
