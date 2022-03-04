
# quickstart

    from alphatims import bruker
    msrun = bruker.TimsTOF(str(msrun_path))

    msrun[frame, scan, precursor, tof, intensity]

# Bounds

## frames
0:msrun.frame_max_index

## scans
0:msrun.scan_max_index

# precursors is a weird array (still trying to figure out)
# I think that 0 is ms level 1 and anything else is level 2+, but not sure
[0, 1, 0, 2 ...]

# tof
0:msrun.tof_max_index
msrun.tof_indices

# intensity
msrun.intensity_max_value
msrun.intensity_min_value


# Slicing

* Negative slicing is not supported and all indiviudal keys are assumed to be
  sorted, disjunct and strictly increasing
* Indices can contain:
  slices, ints, floats, Nones, and/or iterables.

