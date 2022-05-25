from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")


# === import rule for mkpx dataset
module nxstn_mkpx:
    snakefile:
        github(
            "nextstrain/monkeypox",
            path="workflow/snakemake_rules/download_via_lapis.smk",
            branch="lapis2",
        )


use rule download_via_lapis from nxstn_mkpx as imported_lapis_mkpx with:
    output:
        sequences="sequences.fasta",
        metadata="metadata.tsv",


# = consistent with cov below
rule lapis_mkpx:
    output:
        output="results.txt",
    params:
        query="dataFormat=csv",
        api="details",  # aggregated, details, aa-mutations, nuc-mutations, fasta, fasta-aligned,
    shell:
        """
        curl 'https://mpox-lapis.gen-spectrum.org/v1/sample/{params.api:q}?{params.query}' > {output}
        """


# === cov dataset
rule lapis_cov:
    output:
        output="results.txt",
    params:
        query="country=Switzerland&division=Geneva&pangoLineage=AY.1",
        api="details",  # aggregated, details, aa-mutations, nuc-mutations, fasta, fasta-aligned,
    shell:
        """
        curl 'https://lapis.cov-spectrum.org/open/v1/sample/{params.api:q}?{params.query}' > {output}
        """
