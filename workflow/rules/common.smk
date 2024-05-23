from snakemake.utils import validate
import pandas as pd
import numpy as np
import os
import re

##### load config and sample sheets #####


configfile: "config/config.yaml"


#validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_table(config["samples"], dtype=str).set_index(
    ["sample_id", "datatype", "unit"], drop=False
)
samples.index = samples.index.set_levels(
    [i.astype(str) for i in samples.index.levels]
)  # enforce str in index
#validate(samples, schema="../schemas/samples.schema.yaml")

## Wildcard constraints
wildcard_constraints:
    datatype="|".join(samples.datatype.unique())

## Helper functions


def get_se_illumina_fastq(wildcards):
    """Get fastq files of given sample-unit."""
    fastqs = samples.loc[(wildcards.sample, "illumina",  wildcards.unit), ["fq1", "fq2"]].dropna()
    if len(fastqs) == 2:
        raise
    return {"sample": [fastqs.fq1]}

def get_pe_illumina_fastq(wildcards):
    """Get fastq files of given sample-unit."""
    fastqs = samples.loc[(wildcards.sample, "illumina",  wildcards.unit), ["fq1", "fq2"]].dropna()
    if len(fastqs) == 2:
        return {"sample": [fastqs.fq1, fastqs.fq2]}
    raise

def is_single_end(sample, unit):
    """Return True if sample-unit is single end."""
    return pd.isnull(samples.loc[(sample, "illumina", unit), "fq2"])


def get_trimmed_reads(wildcards):
    """Get trimmed reads of given sample-unit."""
    if not is_single_end(**wildcards):
        # paired-end sample
        return expand(
            "results/trimmed/{sample}-{unit}.{group}.fastq.gz",
            group=[1, 2],
            **wildcards
        )
    # single end sample
    return "results/trimmed/{sample}-{unit}.fastq.gz".format(**wildcards)


def get_pbmm2_input(wildcards):
    return samples.loc[(wildcards.sample, "pacbio", wildcards.unit), ["fq1"]]


def get_ont_input(wildcards):
    return samples.loc[(wildcards.sample, "ont", wildcards.unit), ["fq1"]]


# Want the following files
# results/mapped/{datatype}/merged/{sample}.bam
# results/mapped/ont/{sample}.bam
# results/mapped/illumina/{sample}.bam
# results/mapped/pacbio/{sample}.bam
def get_collect_bams_input(wildcards):
    tmp_df = (
            samples
            .reset_index(drop=True)
            .assign(
                n_units_per_sample =
                lambda x: (
                    x
                    .groupby('sample_id')
                    .sample_id
                    .transform('count')
                    )
                )
            )
    targets = {}
    for dt in ['illumina', 'ont', 'pacbio']:
        dt_df = tmp_df.query(f'datatype=="{dt}"')
        for cond in ['==1', '>1']:
            if cond=='>1':
                dt=f'{dt}/merged'
            targets[dt] = (
                    dt_df
                    .query(f'n_units_per_sample{cond}')
                    .sample_id
                    .apply(
                        lambda x: f'results/mapped/{dt}/{x}.bam'
                        )
                    .to_list()
                    )
    target_list = [filename for filegroup in targets.values() for filename in filegroup]
    return target_list


def get_multiqc_input_from_samtools_stats(wildcards):
    bams = get_collect_bams_input(wildcards)
    return [re.sub(r'^results/mapped/(.*)\.bam$', r'results/qc/samtools_stats/\1.txt', s) for s in bams]


def get_multiqc_input_from_deeptools_plotcoverage(wildcards):
    bams = get_collect_bams_input(wildcards)
    return [re.sub(r'^results/mapped/(.*)\.bam$', r'results/qc/deeptools_plotcoverage/coverage/\1.raw', s) for s in bams]


def get_bamcoverages(wildcards):
    bams = get_collect_bams_input(wildcards)
    return [re.sub(r'^results/mapped/(.*)\.bam$', r'results/mapped/bigwig/\1.bw', s) for s in bams]


def get_fastqc_input(wildcards):
    """Get fastq files of given sample-unit."""
    tmp_df = samples.copy()
    tmp_df.index = tmp_df.index.droplevel('datatype')
    return tmp_df.loc[(wildcards.sample, wildcards.unit), ["fq" + wildcards.read]].to_list()


def get_multiqc_input_from_fastqc(wildcards):
    tmp_df = (pd.wide_to_long(
        samples.reset_index(drop=True),
        'fq',
        i=['sample_id','datatype','unit'],
        j='read')
              .dropna()
              .reset_index()
              [['sample_id','unit','read']]
              )
    
    return [f"results/qc/fastqc/{s.sample_id}-{s.unit}-R{s.read}_fastqc.zip" for s in tmp_df.itertuples()]
