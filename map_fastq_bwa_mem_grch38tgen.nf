nextflow.enable.dsl=2

params.publish_dir = ""

process map_fastq {
    input:
        tuple val(reads_name), path(reads)
        val rg
        val sample
    output:
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", enabled: params.publish_dir as boolean
        path "output/out.bam", emit: bam

    container "ghcr.io/coh-apps/coh_app_bwa-0.7.17.grch38tgen:skylake"
    cpus 4
    memory "15 GB"

    script:
        """
            set -Eeuxo pipefail
            
            mkdir -p output

            bwa mem -v 3 -Y -K 10000000 -t 4 -R "${rg}" /database/GRCh38tgen_decoy_alts_hla.fa ${reads} | \
            samtools view -bS - | \
            samtools fixmate --threads 4 -m - - | \
            samtools sort -l 2 -m 2G --threads 4 --output-fmt BAM -o "output/out.bam"
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
