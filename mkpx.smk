
# Doubt this works out of the box
# RUN: include: github("nextstrain/monkeypox", path="Snakefile", branch="master")
# OUTPUT: (cannot find core.smk, so not pulling rest of files)
#> KeyError in line 27 of https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk:
#> 'exclude'
#>   File "/Users/jenchang/github/j23414/test_snakemake_6/mkpx.smk", line 4, in <module>
#>   File "https://github.com/nextstrain/monkeypox/raw/master/Snakefile", line 24, in <module>
#>   File "https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk", line 27, in <module>

# ==== Bespoke rules ==== 

# ==== Importable rules =================

# ==== Connect rules inputs and outputs 