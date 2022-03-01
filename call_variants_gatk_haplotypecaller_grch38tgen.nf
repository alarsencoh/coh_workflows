nextflow.enable.dsl=2

params.publish_dir = ""

process call_variants_gatk_haplotypecaller {
    input:
        path bam
        path reference
    output:
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", enabled: params.publish_dir as boolean
        path "output/out.g.vcf.gz", emit: gvcf

    container "ghcr.io/coh-apps/coh_app_gatk-4.2.2.0.grch38tgen:skylake.docker"
    cpus 4
    memory "15 GB"

    script:
        """
            set -Eeuxo pipefail
            
            mkdir -p output

            gatk HaplotypeCaller \
            --input "${bam}" \
            -O output/out.g.vcf.gz \
            --reference "${reference}" \
            --java-options "-Xmx14G" \
            -ERC GVCF \
            /database/intervals.yaml
        """
}

workflow {
    fastq1 = Channel.fromPath( params.bam )
    output = map_fastq( fastq1,
                        fastq2,
                        params.rg,
                        params.sample )
    emit:
        output
}
