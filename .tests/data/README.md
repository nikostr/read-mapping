Data have been generated using the sample data provided by the PBSIM3 github repo:

https://github.com/yukiteruono/pbsim3

The below scripts have been used to generate the datasets.

# Illumina
```
# Adapted from art documentation
art_illumina \
    --seqSys HS25 \
    --in ../../raw/sample.fasta \
    --paired \
    --len 150 \
    --fcov 2 \
    --mflen 200 \
    --sdev 10 \
    --out short_reads                                                                                       

for f in *.fq; do
    gzip $f
done
```

# ONT
```
# https://github.com/yukiteruono/pbsim3
pbsim \
    --strategy wgs \
    --method qshmm \
    --qshmm $PBSIMDATA/QSHMM-ONT-HQ.model \
    --depth 2 \
    --genome ../../raw/sample.fasta

gzip sd_0001.fastq
```

# Pacbio
```
# https://github.com/yukiteruono/pbsim3/issues/8
pbsim \
    --strategy wgs \
    --method qshmm \
    --qshmm $PBSIMDATA/QSHMM-RSII.model \
    --difference-ratio 22:45:33 \
    --length-mean 15000 \
    --depth 2 \
    --genome ../../raw/sample.fasta \
    --pass-num 10
# https://github.com/yukiteruono/pbsim3/issues/10
samtools view -bS sd_0001.sam > sd_0001.bam
ccs sd_0001.bam sd_0001.fastq.gz
```
