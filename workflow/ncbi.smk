# rule genbank_url:
#     output:
#         url_txt="data/url_txt",
#     run:
#         """
#         #!/usr/bin/env python3
#
#         # Generate URL to download all Monkeypox sequences and their curated metadata
#         # from GenBank via NCBI Virus.
#         #
#         # The URL this program builds is based on the URL for SARS-CoV-2 constructed with
#         #
#         #     https://github.com/nextstrain/ncov-ingest/blob/2a5f255329ee5bdf0cabc8b8827a700c92becbe4/bin/genbank-url
#         #
#         # and observing the network activity at
#         #
#         #     https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide&VirusLineage_ss=Monkeypox%20virus,%20taxid:10244
#
#         from urllib.parse import urlencode
#
#         endpoint = "https://www.ncbi.nlm.nih.gov/genomes/VirusVariation/vvsearch2/"
#         params = {
#             # Search criteria
#             'fq': [
#                 '{!tag=SeqType_s}SeqType_s:("Nucleotide")', # Nucleotide sequences (as opposed to protein)
#                 'VirusLineageId_ss:(10244)',                # NCBI Taxon id for Monkeypox
#             ],
#
#             # Unclear, but seems necessary.
#             'q': '*:*',
#
#             # Response format
#             'cmd': 'download',
#             'dlfmt': 'csv',
#             'fl': ','.join(
#                 ':'.join(names) for names in [
#                     # Pairs of (output column name, source data field).
#                     ('genbank_accession',       'id'),
#                     ('genbank_accession_rev',   'AccVer_s'),
#                     ('database',                'SourceDB_s'),
#                     ('strain',                  'Isolate_s'),
#                     ('region',                  'Region_s'),
#                     ('location',                'CountryFull_s'),
#                     ('collected',               'CollectionDate_s'),
#                     ('submitted',               'CreateDate_dt'),
#                     ('length',                  'SLen_i'),
#                     ('host',                    'Host_s'),
#                     ('isolation_source',        'Isolation_csv'),
#                     ('bioproject_accession',    'BioProject_s'),
#                     ('biosample_accession',     'BioSample_s'),
#                     ('sra_accession',           'SRALink_csv'),
#                     ('title',                   'Definition_s'),
#                     ('authors',                 'Authors_csv'),
#                     ('publications',            'PubMed_csv'),
#                     ('sequence',                'Nucleotide_seq'),
#                 ]
#             ),
#
#             # Stable sort with newest last so diffs work nicely.  Columns are source
#             # data fields, not our output columns.
#             'sort': 'SourceDB_s desc, CollectionDate_s asc, id asc',
#
#             # This isn't Entrez, but include the same email parameter it requires just
#             # to be nice.
#             'email': 'hello@nextstrain.org',
#         }
#         query = urlencode(params, doseq = True, encoding = "utf-8")
#
#         print(f"{endpoint}?{query}")
#         """
#
#
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
#         # ./bin/fetch-from-genbank > {output.genbank_ndjson}
#         genbank_url=`cat {input.genbank_url}`
#         curl "${{genbank_url}}" \
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
