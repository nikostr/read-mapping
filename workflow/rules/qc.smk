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
        mem_mb=threads * 1024
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


rule multiqc:
    input:
        get_multiqc_input_from_samtools_stats,
        get_multiqc_input_from_fastqc,
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
