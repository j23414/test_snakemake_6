# USAGE: snakemake --snakefile mkpx.smk export -c4

from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")

# 1) Importing directly resulted in some config linking errors
# Doubt this works out of the box
# RUN: include: github("nextstrain/monkeypox", path="Snakefile", branch="master")
# OUTPUT: (cannot find core.smk, so not pulling rest of files)
# > KeyError in line 27 of https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk:
# > 'exclude'
# >   File "/Users/jenchang/github/j23414/test_snakemake_6/mkpx.smk", line 4, in <module>
# >   File "https://github.com/nextstrain/monkeypox/raw/master/Snakefile", line 24, in <module>
# >   File "https://github.com/nextstrain/monkeypox/raw/master/workflow/snakemake_rules/core.smk", line 27, in <module>

# 2) Ergo: went with a mix of importable rules
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


use rule mask from augur_reuse as mask_mkpx with:
    input:
        sequences_fasta="data/aligned.fasta",
        mask_txt="data/config/mask.bed",
    output:
        masked_fasta="data/masked.fasta",
    params:
        mask_params=" --mask-from-beginning 1500 --mask-from-end 1000 ",


use rule tree from augur_reuse as tree_mkpx with:
    input:
        alignment_fasta="data/masked.fasta",
    output:
        tree="data/mkpx_raw.tre",


use rule refine from augur_reuse as refine_mkpx with:
    input:
        tree="data/mkpx_raw.tre",
        alignment_fasta="data/masked.fasta",
        metadata_tsv="data/metadata.tsv",
    output:
        refined_tree="data/mkpx.tre",
        node_data_json="data/branch_lengths.json",
    params:
        refine_params=" --timetree --root min_dev --clock-rate 5e-6 --clock-std-dev 3e-6 --coalescent opt --date-inference marginal --clock-filter-iqd 10",


use rule ancestral from augur_reuse as ancestral_mkpx with:
    input:
        tree="data/mkpx.tre",
        alignment_fasta="data/masked.fasta",
    output:
        node_data_json="data/nt_muts.json",
    params:
        ancestral_params=" --inference joint ",


use rule translate from augur_reuse as translate_mkpx with:
    input:
        tree="data/mkpx.tre",
        nt_node_data_json="data/nt_muts.json",
        reference_gb="data/config/reference.gb",
    output:
        node_data_json="data/aa_muts.json",


use rule traits from augur_reuse as traits_mkpx with:
    input:
        tree="data/mkpx.tre",
        metadata_tsv="data/metadata.tsv",
    output:
        node_data_json="data/traits.json",
    params:
        traits_params=" --columns country --confidence --sampling-bias-correction 3 ",


# Rethink export
# Look for a generalized export (arrays? globs?)
rule export:
    input:
        tree="data/mkpx.tre",
        metadata="data/metadata.tsv",
        branch_lengths="data/branch_lengths.json",
        traits="data/traits.json",
        nt_muts="data/nt_muts.json",
        aa_muts="data/aa_muts.json",
        colors="data/config/colors.tsv",
        lat_longs="data/config/lat_longs.tsv",
        description="data/config/description.md",
        auspice_config="data/config/auspice_config.json",
    output:
        auspice_json="auspice/mkpx.json",
        root_sequence="auspice/mkpx_root-sequence.json",
    params:
        export_params=" --include-root-sequence ",
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.traits} {input.nt_muts} {input.aa_muts} \
            --colors {input.colors} \
            --lat-longs {input.lat_longs} \
            --description {input.description} \
            --auspice-config {input.auspice_config} \
            --output {output.auspice_json} \
            {params.export_params}
        """
