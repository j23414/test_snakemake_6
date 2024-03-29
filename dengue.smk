# USAGE: snakemake --snakefile dengue.smk data/dengue_ids.txt -c1

from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")

# 1) Importable rules from modules =================
# module vv_ingest:
#     snakefile:
#         github(
#             "j23414/test_snakemake_6",
#             path="workflow/vv_ingest.smk",
#             branch="main",
#         )

module vv_ingest:
    snakefile:
        "workflow/vv_ingest.smk"

module ncbi:
    snakefile:
        "workflow/ncbi.smk"

# 2) Connect rules

use rule getGenBankIDs from vv_ingest as getDengueIDs with:
    params:
        taxonid=12637,
    output:
        genbank_ids="data/dengue_ids.txt",
        update_date_list="data/dengue_update_date_list.txt"

use rule batchFetchGB from ncbi as batchFetchDengueGB with:
    input:
        genbank_ids="data/dengue_ids.txt",
    output:
        genbank_gb="data/dengue.gb"

use rule genbank_to_nucleotide from ncbi as convert_to_fasta with:
    input:
        genbank_gb="data/dengue.gb",
    output:
        nucleotide_fasta="data/dengue.fasta"

rule fetch_dengue_references:
    output:
        "data/dengue_references.fasta"
    shell:
        """
        #! /usr/bin/env bash
        [[ -d bin ]] || mkdir bin
        [[ -f bin/batchFetchGB.sh ]] || wget -O bin/batchFetchGB.sh https://raw.githubusercontent.com/j23414/mini_nf/main/bin/batchFetchGB.sh
        [[ -f bin/procGenbank.pl ]] || wget -O bin/procGenbank.pl https://raw.githubusercontent.com/j23414/mini_nf/main/bin/procGenbank.pl
        chmod +x bin/*
        
        # Reference strains: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6509522/
        echo "U88536" > data/dengue_references.id
        # KM204119
        echo "U87411" >> data/dengue_references.id
        # M84727,KU725663
        # M29095,AF038403,KM204118  # NGC
        echo "AY099336" >> data/dengue_references.id
        # M93130,KU050695
        echo "AF326825" >> data/dengue_references.id
        # AY947539,KR011349


        bin/batchFetchGB.sh data/dengue_references.id > data/dengue_references.gb
        bin/procGenbank.pl data/dengue_references.gb \
          | sed 's/U88536/REF_DENV1|U88536/' \
          | sed 's/U87411/REF_DENV2|U87411/' \
          | sed 's/AY099336/REF_DENV3|AY099336/' \
          | sed 's/AF326825/REF_DENV4|AF326825/' \
          > data/dengue_references.fasta
        """

rule serotype_dengue:
    input:
        query="data/dengue.fasta",
        reference="data/dengue_references.fasta"
    output:
        denv1="data/DENV1.ids",
        denv2="data/DENV2.ids",
        denv3="data/DENV3.ids",
        denv4="data/DENV4.ids",
        unclassified="data/unclassified.ids",
        dengue_serotypes="data/dengue_serotypes.txt"
    shell:
        """
        #! /usr/bin/env bash
        makeblastdb -in {input.reference} -dbtype nucl
        blastn -db {input.reference} \
          -query {input.query} \
          -num_alignments 1 \
          -outfmt 6 \
          -out blast_output.txt

        cat blast_output.txt \
          | awk -F'|' 'OFS="\t" {{print $1,$3}}' \
          | awk 'OFS="\t" {{print $1,$3}}' \
          > {output.dengue_serotypes}

        cat {output.dengue_serotypes} \
          | awk -F'\t' 'OFS="\t" {{print $1}}' \
          > temp.ids

        grep ">" {input.query} | sed 's/>//g' | grep -v -f temp.ids > {output.unclassified}
        """

use rule genbank_to_protein from ncbi as convert_to_protein with:
    input:
        genbank_gb="data/dengue.gb",
    output:
        protein_fasta="data/dengue_protein.fasta"