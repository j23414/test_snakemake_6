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
rule mkpx_configs:
    output:
        sequences="data/config/sequences.fasta",
        outbreak="data/config/outbreak.fasta",
        metadata="data/config/metadata.tsv",
        auspice="data/config/auspice_config.json",
        colors="data/config/colors.tsv",
        description="data/config/description.md",
        exclude="data/config/exclude.txt",
        genemap="data/config/genemap.gff",
        lat_longs="data/config/lat_longs.tsv",
        mask="data/config/mask.bed",
        reference_fasta="data/config/reference.fasta",
        reference_gb="data/config/reference.gb",
    shell:
        """
        [[ -d data/config ]] || mkdir -p data/config
        cd data
        wget -O master.zip https://github.com/nextstrain/monkeypox/archive/refs/heads/master.zip
        unzip master.zip
        cd ..
        mv data/monkeypox-master/config/* data/config/.
        mv data/monkeypox-master/example_data/* data/config/.
        """


use rule download_via_lapis from nxstn_mkpx as imported_lapis_mkpx with:
    output:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",


use rule augur_filter from augur_reuse as filter_mkpx with:
    input:
        sequences_fasta="data/sequences.fasta",
        metadata_tsv="data/metadata.tsv",
        exclude_txt="data/config/exclude.txt",
    output:
        filtered_fasta="data/filtered.fasta",
    params:
        filter_params="--group-by country year --sequences-per-group 1000 --min-date 1950 --min-length 10000",


use rule run_align from nextalign_reuse as align_mkpx with:
    input:
        sequences_fasta="data/filtered.fasta",
        reference_fasta="data/config/reference.fasta",
    output:
        alignment_fasta="data/aligned.fasta",
    params:
        run_align_params=" --jobs 1 --max-indel 10000 --nuc-seed-spacing 1000 ",
