
rule getGenBankIDs:
    output:
        output="genbank_ids.txt",
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
          > {output}
        """