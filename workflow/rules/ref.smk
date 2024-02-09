rule bwa_meme_index:
    input:
        config['genome'],
    output:
        multiext(
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
    log:
        "results/logs/bwa-meme_index/genome.log",
    params:
        bwa="bwa-meme",
    threads: 16
    wrapper:
        "v3.3.6/bio/bwa-memx/index"
