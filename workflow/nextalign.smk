
rule run_align:
    input:
        sequences_fasta="sequences.fasta",
        reference_gb="reference.gb",
    output:
        alignment_fasta="aligned.fasta",
    params:
        run_align_params=" --max-indel 100 --seed-spacing 100 --jobs 1 ",
    shell:
        """
        nextalign run -v \
          --sequences {input.sequence_fasta} \
          --reference {input.reference_gb} \
          --output-fasta {output.alignment_fasta} \
          {params.run_align_params}
        """
