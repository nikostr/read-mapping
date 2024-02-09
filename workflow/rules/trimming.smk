ruleorder: fastp_pe > fastp_se


rule fastp_se:
    input:
        unpack(get_se_illumina_fastq),
    output:
        trimmed="results/trimmed/{sample}-{unit}.fastq.gz",
        html="results/qc/fastp/{sample}-{unit}.html",
        json="results/qc/fastp/{sample}-{unit}_fastp.json",
    log:
        "results/logs/fastp/{sample}-{unit}.log",
    params:
        adapters='',
        extra='--correction',
    threads: 8
    wrapper:
        "v3.3.6/bio/fastp"


rule fastp_pe:
    input:
        unpack(get_pe_illumina_fastq),
    output:
        trimmed=[
            "results/trimmed/{sample}-{unit}.1.fastq.gz",
            "results/trimmed/{sample}-{unit}.2.fastq.gz",
        ],
        html="results/qc/fastp/{sample}-{unit}.html",
        json="results/qc/fastp/{sample}-{unit}_fastp.json",
    log:
        "results/logs/fastp/{sample}-{unit}.log",
    params:
        adapters='',
        extra='--correction',
    threads: 8
    wrapper:
        "v3.3.6/bio/fastp"
