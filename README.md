# test_snakemake_6

## Modules

> With Snakemake 6.0 and later, it is possible to define external workflows as modules, from which rules can be used by explicitly “importing” them.

```
# Requires a branch or tag
github("j23414/test_snakemake_6", path="workflow/Snakefile", branch="main") #, tag="v1.0.0")
```

```
# auto fix any tab errors
mamba install snakefmt
snakefmt Snakefile
```

```
touch a.txt
snakemake --snakefile Snakefile_local augur_test -c2
```

<details><summary>View output</summary>


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
</details>

Reuse a rule

```
snakemake --snakefile Snakefile_local with_test -c2
```

<details><summary>View output</summary>

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

</details>

## Pull a rule from ncov

```
module ncov_workflow:
    snakefile:
        github("nextstrain/ncov", path="workflow/snakemake_rules/main_workflow.smk", branch="master")    
    config:
        github("nextstrain/ncov", path="defaults/parameters.yaml", branch="master")

use rule * from ncov_workflow as ncov_*

use rule index_sequences from ncov_workflow as index_sequences with:
    input:
        sequences="test.fasta",
    output:
        sequence_index="test_index.tsv.xz"
```

```
 snakemake --snakefile Snakefile_local index_sequences -c2
TypeError in line 9 of https://github.com/nextstrain/ncov/raw/master/workflow/snakemake_rules/main_workflow.smk:
'GithubFile' object is not subscriptable
  File "/Users/jenchang/github/j23414/test_snakemake_6/Snakefile_local", line 28, in <module>
  File "https://github.com/nextstrain/ncov/raw/master/workflow/snakemake_rules/main_workflow.smk", line 9, in <module>
```

Track down `TypeError`




