---
title: "LAPIS: database"
sidebar: toc
maxdepth: 1
sort: 2
---

# LAPIS

Describe what LAPIS is for and how to connect to snakemake rule remotely.

* [LAPIS Docs](https://lapis.cov-spectrum.org/#introduction)


### Recommended include method

**Your\_Local\_Snakefile**

```
from doctest import debug_script
from snakemake.utils import min_version

min_version("6.0")


module lapis_workflow:
    snakefile:
        github("j23414/test_snakemake_6", path="workflow/lapis.smk", branch="main")


use rule lapis from lapis_workflow as lapis with:
    output:
        output="lapis.fasta",
    params:
        query="country=Switzerland&division=Geneva&pangoLineage=AY.1",
        api="fasta",
```

The above should run with:

```
snakemake --snakefile Snakefile -c 2 lapis
```

### View Rule

**workflow/lapis.smk**

```
rule lapis:
    output:
        output="results.txt",
    params:
        query="country=Switzerland&division=Geneva&pangoLineage=AY.1",
        api="details",  # aggregated, details, aa-mutations, nuc-mutations, fasta, fasta-aligned,
    shell:
        """
        curl 'https://lapis.cov-spectrum.org/open/v1/sample/{params.api:q}?{params.query}' > {output}
        """
```
