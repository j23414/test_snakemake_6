# filter_params="--group-by country year --sequences-per-group 1000 --min-date 1950 --min-length 5000"
rule augur_filter:
    input:
        sequences_fasta="sequences.fasta",
        metadata_tsv="metadata.tsv",
        exclude_txt="exclude.txt",
    output:
        filtered_fasta="filtered.fasta",
    params:
        filter_params=" ",
    shell:
        """
        augur filter \
          --sequences {input.sequences_fasta} \
          --metadata {input.metadata_tsv} \
          --exclude {input.exclude_txt} \
          --output {output.filtered_fasta} \
          {params.filter_params} 
        """


# mask_params=" --mask-from-begining 1500 --mask-from-end 1000 "
rule mask:
    input:
        sequences_fasta="sequences.fasta",
        mask_txt="mask.txt",
    output:
        masked_fasta="masked.fasta",
    params:
        mask_params=" ",
    shell:
        """
        augur mask \
          --sequences {input.sequences_fasta} \
          --mask {input.mask_txt} \
          --output {output.masked_fasta} \
          {params.mask_params}
        ls -ltr {output.masked_fasta}
        """


rule tree:
    input:
        alignment_fasta="aligned.fasta",
    output:
        tree="data.tre",
    params:
        tree_params=" ",
    shell:
        """
        augur tree \
          --alignment {input.alignment_fasta} \
          --output {output.tree} \
          {params.tree_params}
        """


# refine_params="--root min_dev  --timetree  --clock-rate 5e-6 --clock-std-dev 3e-6 --coalescent opt --date-inference marginal --clock-filter-iqd 10"
rule refine:
    input:
        tree="data.tre",
        alignment_fasta="aligned.fasta",
        metadata_tsv="metadata.tsv",
    output:
        refined_tree="refined.tre",
        node_data_json="node_data.json",  # branch_lengths.json
    params:
        refine_params="--root min_dev  --timetree --coalescent opt --date-inference marginal --clock-filter-iqd 10",
    shell:
        """
        augur refine \
          --tree {input.tree} \
          --alignment {input.alignment_fasta} \
          --metadata {input.metadata_tsv} \
          --output-tree {output.refined_tree} \
          --output-node-data {output.node_data_json} \
          {params.refine_params}
        """


# ancestral_params="--inference joint"
rule ancestral:
    input:
        tree="data.tre",
        alignment_fasta="alignment.fasta",
    output:
        node_data_json="node_data.json",  # nt_muts.json 
    params:
        ancestral_params="--inference joint",
    shell:
        """
        augur ancestral \
          --tree {input.tree} \
          --alignment {input.alignment_fasta} \
          --output-node-data {output.node_data_json} \
          {params.ancestral_params}
        """


rule translate:
    input:
        tree="data.tre",
        nt_node_data_json="nt_muts.json",
        reference_gb="reference.gb",
    output:
        node_data_json="aa_muts.json",
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequence {input.nt_node_data_json} \
            --reference-sequence {input.reference_gb} \
            --output {output.node_data_json}
        ls {output.node_data_json}
        """


# traits_params = " --columns country --sampling-bias-correction 3 --confidence "
rule traits:
    input:
        tree="data.tre",
        metadata_tsv="metadata.tsv",
    output:
        node_data_json="node_data.json",  # traits.json
    params:
        traits_params=" --confidence ",
    shell:
        """
        augur traits \
          --tree {input.tree} \
          --metadata {input.metadata_tsv} \
          --output {output.node_data_json} \
          {params.traits_params}
        """


# hmm snakemake file array for export?
