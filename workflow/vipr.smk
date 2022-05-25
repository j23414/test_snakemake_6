# query="family=flavi&species=Zika%20virus&fromyear=2013&minlength=5000"
# metadata="genbank,strainname,segment,date,host,country,genotype,species"
rule vipr_fasta:
    output:
        output="vipr_download.fasta",
    params:
        query="family=flavi&species=Zika%20virus&fromyear=2020&minlength=5000",
        metadata="genbank,date",
    shell:
        """
        URL="https://www.viprbrc.org/brc/api/sequence?datatype=genome&{params.query}&metadata={metadata}&output=fasta"

        echo ${{URL}}
        curl ${{URL}} \
          | tr ' ' '_' \
          | sed 's:N/A:NA:g' \
          > {output}
        """


# family="pneumoviridae",
# virus="Respiratory%20syncytial%20virus",
