
rule getGenBankIDs:
    output:
        genbank_ids="genbank_ids.txt",
        update_date_list="genbank_ids_update_date.txt"
    params:
        taxonid="11320",
    shell:
        """
        [[ -d bin ]] || mkdir bin
        [[ -f bin/genbank-url ]] || wget -O bin/genbank-url https://raw.githubusercontent.com/nextstrain/dengue/49b7defc60c3c36652f5a52145649f4a5d82be17/ingest/bin/genbank-url 
        chmod +x bin/*

        URL=$(python bin/genbank-url --taxonid {params.taxonid})

        curl $URL \
          --fail --silent --show-error --http1.1 \
          --header 'User-Agent: https://github.com/nextstrain/dengue (hello@nextstrain.org)' \
          > {output.update_date_list}
        
        cat {output.update_date_list} | awk -F',' '{{print $1}}' > {output.genbank_ids}
        """