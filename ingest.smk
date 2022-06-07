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


# 2) Connect inputs and outputs
use rule fetch_from_genbank from ingest_fetch as fetch_gb with:
    output:
        genbank_ndjson="data/genbank.ndjson",
