
# installation

You will need the netcdf package for xcms to install:
```bash
yay -S netcdf
```

```R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("xcms")
```
