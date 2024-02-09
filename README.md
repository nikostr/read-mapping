# Snakemake workflow: read-mapping

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/nikostr/read-mapping/workflows/Tests/badge.svg?branch=main)](https://github.com/nikostr/read-mapping/actions?query=branch%3Amain+workflow%3ATests)


A Snakemake workflow for mapping long and short reads to a reference genome. Short read mapping is done using BWA-MEME, while long read mapping is done using pbmm2 and minimap2 for pacbio and ONT data respectively.


## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=nikostr%2Fread-mapping).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and its DOI (see above).

# TODO

* Reference the used softwares
* Create option to generate indices for the minimap2 and pbmm2 runs
