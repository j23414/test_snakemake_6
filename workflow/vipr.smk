rule vipr_fasta:
    output:
        output="vipr_download.fasta",
    params:
        family="pneumoviridae",
        virus="Respiratory%20syncytial%20virus",
    shell:
        """
        #MINYEAR=2000
        MINLEN=5000
        METADATA="genbank,strainname,segment,date,host,country,genotype,species"

        URL="https://www.viprbrc.org/brc/api/sequence?datatype=genome&family={params.family}&{params.virus}&minlen=${{MINLEN}}&&metadata=${{METADATA}}&output=fasta"

        echo ${{URL}}
        curl ${{URL}} \
          | tr '-' '_' \
          | tr ' ' '_' \
          | sed 's:N/A:NA:g' \
          > {output}
        """
