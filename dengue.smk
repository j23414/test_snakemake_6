# USAGE: snakemake --snakefile dengue.smk -c4

from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")

# 1) Importable rules from modules =================
module vv_ingest:
    snakefile:
        github(
            "j23414/test_snakemake_6",
            path="workflow/vv_ingest.smk",
            branch="main",
        )

# 2) Connect rules

use rule getGenBankIDs from vv_ingest as getDengueIDs with:
    params:
        taxonid=12637,
    output:
        output="data/dengue_ids.txt",