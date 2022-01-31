nextflow.enable.dsl=2

process merge_bams {
    input:
        file "input_??.bam"
        val sample
    output:
        file "${sample}.bam"
        file "${sample}.bam.bai"

    container "ghcr.io/coh-apps/coh_app_samtools-1.13:skylake"
    cpus 4
    memory '15 GB'

    """
        set -Eeuxo pipefail
        samtools merge --threads 4 -c -f -l 6 '${sample}.bam' input_??.bam
        samtools index '${sample}.bam'
    """
}

workflow {
    bams = Channel.fromPath( params.bams ).collect()
    merge_bams( bams, params.sample )
}
