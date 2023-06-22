from snakemake.utils import min_version
min_version("6.0")

# Use default pathogen build config if no configs are provided
if not config:
    configfile: "config/config_dengue.yaml"
# Use default ingest config if no `transform` config is provided
if not config.get("transform"):
    configfile: "ingest/config/config.yaml"

# Add the hard-coded ingest basedir to the workflow config so that we can
# pass it to the module ingest workflow. This will allow shell scripts to
# use the proper paths for local script invocation since we cannot set the
# workdir separately for module workflows.
# This work around is based on https://stackoverflow.com/a/66890412
config["ingest_basedir"] = f"{workflow.current_basedir}/ingest"

serotypes = ['all', 'denv1', 'denv2', 'denv3', 'denv4']

rule all:
    input:
        metadata_tsvs = expand("data/metadata_{serotype}.tsv.zst", serotype=serotypes)

module ingest_workflow:
    snakefile:
      github(
            "nextstrain/dengue",
            path="ingest/Snakefile",
            branch="new_ingest_one_snakefile",
        )
    config: config
    prefix: "ingest"

use rule * from ingest_workflow as ingest_*

rule mv_ingest_data:
    input:
        sequences="ingest/data/sequences_{serotype}.fasta.zst",
        metadata="ingest/data/metadata_{serotype}.tsv.zst",
    output:
        sequences="data/sequences_{serotype}.fasta.zst",
        metadata="data/metadata_{serotype}.tsv.zst",
    shell:
        """
        mv {input.sequences} {output.sequences}
        mv {input.metadata} {output.metadata}
        """