# test_snakemake_6

## Wrappers

* [Wrapper repository](https://github.com/snakemake/snakemake-wrappers/tree/0.2.0)

```
bio/
 |_ bcftools
 |_ bwa/mem
 |_ delly
 |_ sambamba/sort
 |_ samtools
```

## Modules

> With Snakemake 6.0 and later, it is possible to define external workflows as modules, from which rules can be used by explicitly “importing” them.

```
github("j23414/test_snakemake_6", path="workflow/Snakefile") #, tag="v1.0.0")
```

```
mamba install snakefmt
snakefmt Snakefile
```

```
touch a.txt
snakemake --snakefile Snakefile_local augur_test -c2
```

which gives:

```
Building DAG of jobs...
Using shell: /bin/bash
Provided cores: 2
Rules claiming more threads will be scaled down.
Job stats:
job           count    min threads    max threads
----------  -------  -------------  -------------
augur_test        1              1              1
total             1              1              1

Select jobs to execute...

[Thu May 19 10:46:33 2022]
rule augur_test:
    input: a.txt
    output: a_out.txt
    jobid: 0
    resources: tmpdir=/var/folders/wt/gw5b79wn4sjcpny6d0x4p1680000gn/T

[Thu May 19 10:46:33 2022]
Finished job 0.
1 of 1 steps (100%) done
Complete log: .snakemake/log/2022-05-19T104632.920696.snakemake.log
```

Reuse a rule

```
snakemake --snakefile Snakefile_local with_test -c2
```

```
Building DAG of jobs...
Using shell: /bin/bash
Provided cores: 2
Rules claiming more threads will be scaled down.
Job stats:
job          count    min threads    max threads
---------  -------  -------------  -------------
with_test        1              1              1
total            1              1              1

Select jobs to execute...

[Thu May 19 10:48:37 2022]
rule with_test:
    input: b.txt
    output: c.txt
    jobid: 0
    resources: tmpdir=/var/folders/wt/gw5b79wn4sjcpny6d0x4p1680000gn/T

[Thu May 19 10:48:37 2022]
Finished job 0.
1 of 1 steps (100%) done
Complete log: .snakemake/log/2022-05-19T104836.402734.snakemake.log
```




