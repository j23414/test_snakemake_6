
rule run_align:
    input:
        sequences_fasta="sequences.fasta",
        reference_fasta="reference.fasta",
    output:
        alignment_fasta="aligned.fasta",
    params:
        run_align_params=" --max-indel 10000 --seed-spacing 1000 --jobs 1 ",
    shell:
        """
            nextalign run \
              --sequences {input.sequences_fasta} \
              --reference {input.reference_fasta} \
              --output-fasta {output.alignment_fasta} \
              {params.run_align_params}
        ls -ltr {output.alignment_fasta}
        """
