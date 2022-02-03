nextflow.enable.dsl=2

params.publish_dir = ""

process merge_bams {
    input:
        path "input_??.bam"
        val sample
    output:
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", enabled: params.publish_dir as boolean
        path "output/out.bam", emit: bam
        path "output/out.bam.bai", emit: bam_bai

    container "ghcr.io/coh-apps/coh_app_samtools-1.13:skylake"
    cpus 4
    memory '15 GB'

    """
        set -Eeuxo pipefail

        mkdir -p output

        samtools merge --threads 4 -c -f -l 6 output/out.bam input_??.bam
        samtools index output/out.bam
    """
}

workflow {
    bams = Channel.fromPath( params.bams ).collect()
    merge_bams( bams, params.sample )
}
