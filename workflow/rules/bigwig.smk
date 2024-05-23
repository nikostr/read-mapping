rule deeptools_bamcoverage:
    input:
        bam="results/mapped/{dir}/{sample}.bam",
        bai="results/mapped/{dir}/{sample}.bam.bai",
    output:
        "results/mapped/bigwig/{dir}/{sample}.bw",
    params:
        effective_genome_size="",
    log:
        "results/logs/bamcoverage/{dir}/{sample}.log",
    wrapper:
        "v3.10.2/bio/deeptools/bamcoverage"


rule gather_bamcoverage:
    input:
        get_bamcoverages,
