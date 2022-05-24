---
title: "ViPR: Pull data"
sidebar: toc
maxdepth: 1
sort: 1
---

# Case 1: Pull data

Describe problem here, split out into how to connect snakemake rules

### Recommended parameters

```
nextflow run isugifNF/polishCLR --main \
  --primary_assembly "data/primary.fasta" \
  --mitocondrial_assembly "data/mitochondrial.fasta" \
  --illiumina_reads "data/illumina/*_{R1,R2}.fasta.bz" \
  --pacbio_reads "data/pacbio/pacbio.subreads.bam" \
  --step 1 \
  --arrow01 \
  -profile slurm
```
