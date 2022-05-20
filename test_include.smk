build_dir = "results"
auspice_dir = "auspice"

rule all:
    input:
        auspice_json = auspice_dir + "/testvirus.json"

# renames the last output file to a generic auspice.json and root sequence
rule rename:
    input:
        auspice_json = auspice_dir + "/testvirus_global.json",
        root_sequence = auspice_dir + "/testvirus_global_root-sequence.json"
    output:
        auspice_json = auspice_dir + "/testvirus.json",
        root_sequence = auspice_dir + "/testvirus_root-sequence.json"
    shell:
        """
        mv {input.auspice_json} {output.auspice_json}
        mv {input.root_sequence} {output.root_sequence}
        """

include: github("nextstrain/monkeypox", path="workflow/snakemake_rules/prepare.smk", branch="master")
# prepare (concat all seqs and metadata (drop metadata header??)


include: github("nextstrain/monkeypox", path="workflow/snakemake_rules/core.smk", branch="master")
# augur filter
# nextalign
# augur mask
# augur tree
# augur refine
# augur ancestral
# augur translate
# augur traits
# augur export

rule clean:
    message: "Removing directories: {params}"
    params:
        build_dir,
        auspice_dir
    shell:
        "rm -rfv {params}"