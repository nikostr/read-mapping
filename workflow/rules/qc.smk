rule fastqc:
    input:
        unpack(get_fastqc_input),
    output:
        html="results/qc/fastqc/{sample}-{unit}-R{read}.html",
        zip="results/qc/fastqc/{sample}-{unit}-R{read}_fastqc.zip",
    params:
        "--quiet",
    log:
        "results/logs/fastqc/{sample}-{unit}-R{read}.log",
    threads: 16
    resources:
        mem_mb=lambda w, input, threads: threads * 1024
    wrapper:
        "v3.3.6/bio/fastqc"


rule samtools_stats:
    input:
        "results/mapped/{dir}/{sample}.bam",
    output:
        "results/qc/samtools_stats/{dir}/{sample}.txt",
    params:
        extra="",  # Optional: extra arguments.
        region="",  # Optional: region string.
    log:
        "results/logs/samtools_stats/{dir}/{sample}.log",
    wrapper:
        "v3.3.6/bio/samtools/stats"


rule deeptools_plotcoverage:
    input:
        #bams=["a.bam"],
        #bais=["a.bam.bai"],
        bams="results/mapped/{dir}/{sample}.bam",
        bais="results/mapped/{dir}/{sample}.bam.bai",
    output:
        #plot="coverage.png",
        plot="results/qc/deeptools_plotcoverage/{dir}/{sample}.png",
        # Optional raw counts
        #raw_counts="coverage.raw",
        raw_counts="results/qc/deeptools_plotcoverage/coverage/{dir}/{sample}.raw",
        # Optional metrics
        #metrics="coverage.metrics",
    params:
        extra="",
    log:
        "results/logs/deeptools_plotcoverage/{dir}/{sample}.log",
    wrapper:
        "v3.10.2/bio/deeptools/plotcoverage"


rule multiqc:
    input:
        get_multiqc_input_from_samtools_stats,
        get_multiqc_input_from_fastqc,
        get_multiqc_input_from_deeptools_plotcoverage,
        expand(
            "results/qc/fastp/{s.sample_id}-{s.unit}_fastp.json", s=samples.query('datatype=="illumina"').itertuples()
        ),
    output:
        report(
            "results/qc/multiqc.html",
            caption="../report/multiqc.rst",
            category="Quality control",
        ),
        directory("results/qc/multiqc_data"),
    params:
        extra="--data-dir",  # Optional: extra parameters for multiqc.
        use_input_files_only=True,
    log:
        "results/logs/multiqc.log",
    wrapper:
        "v3.3.6/bio/multiqc"
