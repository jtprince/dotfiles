
https://github.com/boecker-lab/sirius/releases

unzip sirius-5.8.2-linux64.zip

ln -sf ~/src/sirius/bin/sirius ~/.local/bin/

# mgf or .ms file
# .ms format
https://boecker-lab.github.io/docs.sirius.github.io/io/#sirius-ms-format

    >compound: The name of the measured compound (or any placeholder). mandatory.
    >parentmass: the m/z of the parent peak
    >formula: The molecular formula of the compound.
    >ion: the ionization mode. See for the format of ion modes.
    >charge: is redundant if you already provided the ion mode. (1 or -1).
    >ms1: All peaks after this line are interpreted as MS peaks
    >ms2: All peaks after this line are interpreted as MS/MS peaks
    >collision: Same as `>ms2`, but you can specify the collision energy too

example
-------
>compound Gentiobiose
>formula C12H22O11
>ionization \[M+Na\]+
>parentmass 365.10544

>ms1
365.10543 85.63 366.10887 11.69 367.11041 2.67

>collision 20
185.041199 4034.674316
203.052597 12382.624023
...

# Open the gui
sirius

# annotate spectra
sirius -o output -i spectra.ms formula -c 10 write-summaries

# produce detailed tree output(json and graphviz input)
sirius -i output ftree-export --json --dot --all --output ftree-output
dot <somefile>.dot -Tpng -o tree.png

# Another example from Efi Kontou (tweaked)
sirius \
    --input example.ms \
    --project ./sirius_out \
    formula \
    --profile='qtof' \
    --ions-considered='[M+H]+,[M-H2O+H]+,[M+Na]+,[M+NH4]+' \
    --elements-enforced='CHN[15]OS[4]Cl[2]P[2]' \
    --compound-timeout=100 \
    --candidates=10

# Appendix

spectra.complete.ms
[focus is on the formatting not correctness/coherence for this compound]
---------
>compound DEHP
>parentmass: 390.27703
>formula C24H37O4

>ms1
390.27703 100
391.28039 26

>ms2
57.070099 10143480.0
65.038597 511509.09375
71.085701 16105630.0
93.033501 413773.90625
113.132599 1283183.125
121.028603 2821603.25
121.039703 363531.09375
149.023499 123207080.0
163.039093 3117786.75
167.034103 15592827.0
181.049606 2586962.75
279.159485 2500050.75
391.284912 281438.8125
