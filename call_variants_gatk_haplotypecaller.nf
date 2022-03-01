nextflow.enable.dsl=2

params.publish_dir = ""

process call_variants_gatk_haplotypecaller {
    input:
        path bam
        path reference
        path reference_fai
        path reference_dict
        each interval
    output:
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", enabled: params.publish_dir as boolean
        path "output/out.g.vcf.gz", emit: gvcf

    container "ghcr.io/coh-apps/coh_app_gatk-4.2.2.0:skylake.docker"
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
            ${interval}
        """
}

workflow {
    bam = Channel.fromPath( params.bam )
    reference = Channel.fromPath( params.reference )
    reference_fai = Channel.fromPath( params.reference_fai )
    reference_dict = Channel.fromPath( params.reference_dict )
    output = map_fastq( bam,
                        reference,
                        reference_fai,
                        reference_dict )
    emit:
        output
}
