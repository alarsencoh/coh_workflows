nextflow.enable.dsl=2

process map_fastq {
    input:
        file "fastq1_??.fq"
        file "fastq2_??.fq"
        val rg
        val sample
    output:
        file "${sample}.bam"

    container "ghcr.io/coh-apps/coh_app_bwa-0.7.17.grch38tgen:skylake"
    cpus 4
    memory '15 GB'

    script:
        """
            set -Eeuxo pipefail
            bwa mem -v 3 -Y -K 10000000 -t 4 -R "${rg}" \
            /database/GRCh38tgen_decoy_alts_hla.fa \
            fastq1_??.fq fastq2_??.fq | \
            samtools view -bS - | \
            samtools fixmate --threads 4 -m - - | \
            samtools sort -l 2 -m 2G --threads 4 --output-fmt BAM -o "${sample}.bam"
        """
}

workflow {
    fastq1 = Channel.fromPath( params.fastq1 )
    fastq2 = Channel.fromPath( params.fastq2 )
    output = map_fastq( fastq1,
                        fastq2,
                        params.rg,
                        params.sample )
    emit:
        output
}
