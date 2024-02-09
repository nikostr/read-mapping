ruleorder: pbmm2_align > samtools_index
rule bwa_memx_meme:
    input:
        reads=get_trimmed_reads,
        reference=config['genome'],
        idx=multiext(
            config['genome'],
            ".0123",
            ".amb",
            ".ann",
            ".pac",
            ".pos_packed",
            ".suffixarray_uint64",
            ".suffixarray_uint64_L0_PARAMETERS",
            ".suffixarray_uint64_L1_PARAMETERS",
            ".suffixarray_uint64_L2_PARAMETERS",
        ),
    output:
        temp("results/mapped/illumina/{sample}-{unit}.bam"),
    log:
        "results/logs/bwa_memx/{sample}-{unit}.log",
    params:
        bwa="bwa-meme",
        extra=r"-R '@RG\tID:{sample}-{unit}\tSM:{sample}-{unit}' -M",
        sort="samtools",  # Can be 'none' or 'samtools or picard'.
        sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra="",  # Extra args for samtools.
        dedup="mark",  # Can be 'none' (default), 'mark' or 'remove'.
        dedup_extra="-M",  # Extra args for samblaster.
        exceed_thread_limit=True,  # Set threads als for samtools sort / view (total used CPU may exceed threads!)
        embed_ref=True,  # Embed reference when writing cram.
    threads: 16
    wrapper:
        "v3.3.6/bio/bwa-memx/mem"


rule samtools_index:
    input:
        "{dir}/{sample}.bam",
    output:
        "{dir}/{sample}.bam.bai",
    log:
        "results/logs/samtools_index/{dir}/{sample}.log",
    params:
        extra="",  # optional params string
    threads: 4  # This value - 1 will be sent to -@
    wrapper:
        "v3.3.6/bio/samtools/index"


rule pbmm2_align:
    input:
        reference=config['genome'], # can be either genome index or genome fasta
        query=get_pbmm2_input, # can be either unaligned bam, fastq, or fasta
    output:
        bam=temp("results/mapped/pacbio/{sample}-{unit}.bam"),
        index=temp("results/mapped/pacbio/{sample}-{unit}.bam.bai"),
    log:
        "results/logs/pbmm2_align/{sample}-{unit}.log",
    params:
        preset="CCS", # SUBREAD, CCS, HIFI, ISOSEQ, UNROLLED
        sample="{sample}-{unit}", # sample name for @RG header
        extra="--sort", # optional additional args
        loglevel="INFO",
    threads: 16
    wrapper:
        "v3.3.6/bio/pbmm2/align"


rule minimap2_bam_sorted:
    input:
        target=config['genome'],  # can be either genome index or genome fasta
        query=get_ont_input,
    output:
        temp("results/mapped/ont/{sample}-{unit}.bam"),
    log:
        "results/logs/minimap2/{sample}-{unit}.log",
    params:
        extra="-x map-ont",  # optional
        sorting="coordinate",  # optional: Enable sorting. Possible values: 'none', 'queryname' or 'coordinate'
        sort_extra="",  # optional: extra arguments for samtools/picard
    threads: 3
    wrapper:
        "v3.3.6/bio/minimap2/aligner"


rule samtools_merge:
    input:
        lambda w: expand(
            "results/mapped/{datatype}/{sample}-{unit}.bam",
            datatype=samples.loc[w.sample].datatype,
            sample=w.sample,
            unit=samples.loc[w.sample].unit,
        ),
    output:
        "results/mapped/{datatype}/merged/{sample}.bam",
    log:
        "results/logs/samtools_merge/{datatype}/{sample}.log",
    params:
        extra="",  # optional additional parameters as string
    threads: 16
    wrapper:
        "v3.3.6/bio/samtools/merge"


rule rename_single_unit_samples:
    input:
        bam=lambda w: expand(
                "results/mapped/{{datatype}}/{{sample}}-{unit}.bam",
                unit=samples.loc[w.sample, w.datatype].unit
                ),
        bai=lambda w: expand(
                "results/mapped/{{datatype}}/{{sample}}-{unit}.bam.bai",
                unit=samples.loc[w.sample, w.datatype].unit
                ),
    output:
        bam="results/mapped/{datatype}/{sample}.bam",
        bai="results/mapped/{datatype}/{sample}.bam.bai",
    shell:
        "mv {input.bam} {output.bam} "
        " && "
        "mv {input.bai} {output.bai} "
