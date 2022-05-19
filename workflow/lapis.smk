rule lapis:
    output:
        output="results.txt",
    params:
        query='country=Switzerland&division=Geneva&pangoLineage=AY.1',
        api='details',  # aggregated, details, aa-mutations, nuc-mutations, fasta, fasta-aligned,
    shell:
        """
        curl 'https://lapis.cov-spectrum.org/open/v1/sample/{params.api:q}?{params.query}' > {output}
	"""
