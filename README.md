![Perl CI](https://github.com/FabianDeister/Library_curation_BOLD/actions/workflows/ci.yml/badge.svg)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10975576.svg)](https://doi.org/10.5281/zenodo.10975576)
[![DOI](https://zenodo.org/badge/DOI/10.48546/WORKFLOWHUB.WORKFLOW.833.1.svg)](https://doi.org/10.48546/WORKFLOWHUB.WORKFLOW.833.1)

# Library curation BOLD

![alt text](doc/IBOL_LOGO_TRANSPARENT.png)

This repository contains scripts and synonymy data for pipelining the 
automated curation of [BOLD](https://boldsystems.org) data dumps in 
BCDM TSV format. The goal is to implement the classification of barcode 
reference sequences as is being developed by the 
[BGE](https://biodiversitygenomics.eu) consortium. A living document
in which these criteria are being developed is located
[here](https://docs.google.com/document/d/18m-7UnoJTG49TbvTsq_VncKMYZbYVbau98LE_q4rQvA/edit).

A further goal of this project is to develop the code in this repository
according to the standards developed by the community in terms of automation,
reproducibility, and provenance. In practice, this means including the
scripts in a pipeline system such as [snakemake](https://snakemake.readthedocs.io/),
adopting an environment configuration system such as
[conda](https://docs.conda.io/), and organizing the folder structure
in compliance with the requirements of
[WorkFlowHub](https://workflowhub.eu/). The latter will provide it with 
a DOI and will help generate [RO-crate](https://www.researchobject.org/ro-crate/)
documents, which means the entire tool chain is FAIR compliant according
to the current state of the art.

## Install
Clone the repo:
```{shell}
git clone https://github.com/FabianDeister/Library_curation_BOLD.git
```
Change directory: 
```{shell}
cd Library_curation_BOLD
```
The code in this repo depends on various tools. These are managed using
the `mamba` program (a drop-in replacement of `conda`). The following
sets up an environment in which all needed tools are installed:

```{shell}
mamba env create -f environment.yml
```

Once set up, this is activated like so:

```{shell}
mamba activate bold-curation
```

## How to run
### Bash
Although the aim of this project is to integrate all steps of the process
in a simple snakemake pipeline, at present this is not implemented. Instead,
the steps are executed individually on the command line as perl scripts
within the conda/mamba environment. Because the current project has its own
perl modules in the `lib` folder, every script needs to be run with the 
additional include flag to add the module folder to the search path. Hence,
the invocation looks like the following inside the scripts folder:

```{shell}
perl -I../../lib scriptname.pl -arg1 val1 -arg2 val2
```
### snakemake

Follow the installation instructions above.

Update config/config.yml to define your input data.

Navigate to the directory "workflow" and type:
```{shell}
snakemake -p -c {number of cores} target
```

If running on an HPC cluster with a SLURM scheduler you could use a bash script like this one:
```{shell}
#!/bin/bash
#SBATCH --partition=hour
#SBATCH --output=job_curate_bold_%j.out
#SBATCH --error=job_curate_bold_%j.err
#SBATCH --mem=24G
#SBATCH --cpus-per-task=2

source activate bold-curation

snakemake -p -c 2 target

echo Complete!
```
