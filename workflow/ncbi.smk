
# rule fetch_from_genbank:
#     input:
#         genbank_url=rules.genbank_url.output.url_txt,
#     output:
#         genbank_csv="data/genbank.csv",
#     params:
#         user_agent="https://github.com/nextstrain/monkeypox",
#         email="hello@nextstrain.org",
#     shell:
#         """
#         # Well this is kinda horrifying
#         curl "https://www.ncbi.nlm.nih.gov/genomes/VirusVariation/vvsearch2/?fq=%7B%21tag%3DSeqType_s%7DSeqType_s%3A%28%22Nucleotide%22%29&fq=VirusLineageId_ss%3A%282697049%29&q=%2A%3A%2A&cmd=download&dlfmt=csv&fl=genbank_accession%3Aid%2Cgenbank_accession_rev%3AAccVer_s%2Cdatabase%3ASourceDB_s%2Csra_accession%3ASRALink_ss%2Cstrain%3AIsolate_s%2Cregion%3ARegion_s%2Clocation%3ACountryFull_s%2Ccollected%3ACollectionDate_s%2Csubmitted%3ACreateDate_dt%2Cpango_lineage%3ALineage_s%2Clength%3ASLen_i%2Chost%3AHost_s%2Cisolation_source%3AIsolation_csv%2Cbiosample_accession%3ABioSample_s%2Ctitle%3ADefinition_s%2Cauthors%3AAuthors_csv%2Cpublications%3APubMed_csv%2Csequence%3ANucleotide_seq&sort=SourceDB_s+desc%2C+CollectionDate_s+asc%2C+id+asc&email=hello%40nextstrain.org" \
#           --fail \
#           --silent \
#           --show-error \
#           --http1.1 \
#           --header 'User-Agent: {params.user_agent} (params.email)' \
#           > {output.genbank_csv}
#         """
#
#
# rule csv_to_ndjson:
#     input:
#         genbank_csv="data/genbank.csv",
#     output:
#         genbank_ndjson="data/genbank.ndjson",
#     run:
#         """
#         #! /usr/bin/env python3
#         # Copied from "bin/csv-to-ndjson" in nextstrain/ncov-ingest:
#         # https://github.com/nextstrain/ncov-ingest/blob/2a5f255329ee5bdf0cabc8b8827a700c92becbe4/bin/csv-to-ndjson
#         # Convert CSV on stdin to NDJSON on stdout.
#
#         import csv
#         import json
#         from sys import stdin, stdout
#
#         # 200 MiB; default is 128 KiB
#         csv.field_size_limit(200 * 1024 * 1024)
#
#         for row in csv.DictReader(stdin):
#             json.dump(row, stdout, allow_nan = False, indent = None, separators = ',:')
#             print()
#         """


rule batchFetchGB:
    input:
        genbank_ids="data/rsv.ids",
    output:
        genbank_gb="data/rsv.gb",
    params:
        batch=100,
    shell:
        """
        #! /usr/bin/env bash
        # Auth: Jennifer Chang
        # Date: 2018/05/14

        set -e
        set -u

        # ======================= USAGE
        # if [[ $# -lt 1 ]]; then
        #   echo "USAGE: bash batchFetchGB.sh [genbank.ids] > [genbank.gb]"          >&2
        #   echo "  Given a file with a list of GenBank IDS, separated by newlines"  >&2
        #   echo "  Return a the concatinated genbanks from NCBI, fetched in batches">&2
        #   echo "     of 100 at a time" >&2
        #   echo " " >&2
        #   exit 0
        # fi

        # ======================= Variables
        NUM=0
        QUERY=""
        BATCH={params.batch}      # Fetch in batches of 50, 100, etc
        FILE=${{BATCH}}  # Starting batch

        # ======================= Main
        GBLIST={input.genbank_ids}

        [[ -d gb ]] || mkdir gb

        TOT=`grep -cv "^$" ${{GBLIST}}`
        while read IDS
        do
            if [ ${{NUM}} -ge ${{BATCH}} ]
            then
                echo "===== Fetching $((FILE-BATCH+1)) to ${{FILE}} of ${{TOT}} total Genbank IDs " >&2
                [[ -f gb/${{FILE}}.gb ]] || sleep 1
                [[ -f gb/${{FILE}}.gb ]] || curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&amp;id=${{QUERY}};rettype=gb&amp;retmode=text" > gb/${{FILE}}.gb
                NUM=1;
                QUERY="${{IDS}}";
                FILE=$((FILE+BATCH));
            else
                NUM=$((NUM+1))
                QUERY="${{QUERY}},${{IDS}}"
            fi
        done < ${{GBLIST}}

        if [ ${{NUM}} -gt 0 ]
        then
            echo "===== Fetching $((FILE-BATCH+1)) to ${{TOT}} of ${{TOT}} total Genbank IDs " >&2
            [[ -f gb/${{FILE}}.gb ]] || sleep 1
            [[ -f gb/${{FILE}}.gb ]] || curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&amp;id=${{QUERY}};rettype=gb&amp;retmode=text" > gb/${{FILE}}.gb
        fi

        cat gb/*.gb > {output.genbank_gb}

        rm -rf gb
        """


rule subset_new_ids:
    input:
        genbank_ids="data/rsv.ids",
        genbank_gb="data/cache.gb",
    output:
        new_ids="data/new.ids",
    shell:
        """
        #! /usr/bin/env bash
        grep -e "^LOCUS" -e "ACCESSION" {input.genbank_gb} \
          | awk "{{print \$2}}" \
          | sort \
          | uniq \
          > _old.ids  # watch out for name collisions
        cat {input.genbank_ids} \
          | sort \
          | uniq \
          > _new.ids
        comm -13 _old.ids _new.ids > {output.new_ids}
        """


# ==== NCBI Datasets command
# https://www.ncbi.nlm.nih.gov/datasets/docs/v1/download-and-install/

# Zika virus = 64320,
# Human orthopneumovirus (HRSV) = 11250,
# Measles = 351680,
# Dengue = 12637,


rule datasets_summary:
    output:
        out_file="data/stdout.txt",
    params:
        taxon="Zika virus",
    shell:
        """
        #! /usr/bin/env bash
        datasets summary genome taxon "{params.taxon}" &> {output.out_file}
        """
