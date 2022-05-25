from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")

# Doubt this works out of the box
# RUN: include: github("nextstrain/monkeypox", path="Snakefile", branch="master")
# OUTPUT: (cannot find core.smk, so not pulling rest of files)
# > KeyError in line 27 of https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk:
# > 'exclude'
# >   File "/Users/jenchang/github/j23414/test_snakemake_6/mkpx.smk", line 4, in <module>
# >   File "https://github.com/nextstrain/monkeypox/raw/master/Snakefile", line 24, in <module>
# >   File "https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk", line 27, in <module>


# ==== Importable rules from modules =================
module nxstn_mkpx:
    snakefile:
        github(
            "nextstrain/monkeypox",
            path="workflow/snakemake_rules/download_via_lapis.smk",
            branch="lapis2",
        )


module augur_reuse:
    snakefile:
        github("j23414/test_snakemake_6", path="workflow/augur.smk", branch="main")


module nextalign_reuse:
    snakefile:
        github("j23414/test_snakemake_6", path="workflow/nextalign.smk", branch="main")


# ==== Main Workflow, start connectedd imported and bespoke rules
use rule download_via_lapis from nxstn_mkpx as imported_lapis_mkpx with:
    output:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",


# use rule filter from augur_reuse with:
#     input:
#         sequences_fasta="data/sequences.fasta",
#         metadata_tsv="data/metadata_tsv",
#         exclude_txt="config/exclude.txt",
