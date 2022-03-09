nextflow.enable.dsl=2

params.publish_dir = ""

process map_fastq {
    input:
        tuple val(reads_name), path(reads)
        val rg
        val sample
        path reference_fa
        path reference_fa_ann
        path reference_fa_amb
        path reference_fa_bwt
        path reference_fa_pac
        path reference_fa_sa
    output:
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", enabled: params.publish_dir as boolean
        path "output/out.bam", emit: bam

    container "ghcr.io/coh-apps/coh_app_bwa-0.7.17:skylake.docker"
    cpus 4
    memory "15 GB"

    script:
        """
            set -Eeuxo pipefail
            
            mkdir -p output

            bwa mem -v 3 -Y -K 10000000 -t 4 -R "${rg}" ${reference_fa} ${reads} | \
            samtools view -bS - | \
            samtools fixmate --threads 4 -m - - | \
            samtools sort -l 2 -m 2G --threads 4 --output-fmt BAM -o "output/out.bam"
        """
}

workflow {
    fastq1 = Channel.fromPath( params.fastq_pairs )
    output = map_fastq( fastq_pairs,
                        params.rg,
                        params.sample,
                        params.reference,
                        params.reference_ann,
                        params.reference_amb,
                        params.reference_bwt,
                        params.reference_pac,
                        params.reference_sa )
    emit:
        output
}
