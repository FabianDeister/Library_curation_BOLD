# Library curation BOLD

![alt text](doc/library_curation_image.jpg)

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

 
