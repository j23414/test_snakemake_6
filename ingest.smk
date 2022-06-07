# USAGE: snakemake --snakefile ingest.smk fetch_gb -c4

from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")


# 1) Importable rules from modules =================
# Hmm scripts in bin, but easier to take apart then original
# nextflow can find a remote bin folder, okay, end rant
module ingest_fetch:
    snakefile:
        github(
            "nextstrain/monkeypox",
            path="ingest/workflow/snakemake_rules/fetch_sequences.smk",
            branch="master",
        )


module ingest_transform:
    snakefile:
        github(
            "nextstrain/monkeypox",
            path="ingest/workflow/snakemake_rules/transform.smk",
            branch="master",
        )


module ncbi:
    snakefile:
        github(
            "j23414/test_snakemake_6",
            path="workflow/ncbi.smk",
            branch="main",
        )


# 2) Connect inputs and outputs
# use rule fetch_from_genbank from ingest_fetch as fetch_gb with:
#     output:
#         genbank_ndjson="data/genbank.ndjson",


use rule subset_new_ids from ncbi as new_ids with:
    input:
        genbank_ids="data/rsv.ids",
        genbank_gb="data/rsv.gb",
    output:
        new_ids="data/new.ids",


use rule batchFetchGB from ncbi as fetch_gb with:
    input:
        genbank_ids="data/new.ids",
    output:
        genbank_gb="data/new.gb",


use rule datasets_summary from ncbi as summary with:
    output:
        stdout="data/test_out.txt",
