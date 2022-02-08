nextflow.enable.dsl=2

process samtools_fixmate {
    input:
        file bam
    output:
        file "out.bam"

    container "ghcr.io/coh-apps/coh_app_samtools-1.13:skylake.docker"
    cpus 4
    memory '15 GB'

    script:
        """
            set -Eeuxo pipefail
            ls -lart
            samtools merge --threads ${params.samtoolsCpus} -c -f -l 6 '${sampleName}.bam' ${f.join(' ')}
            samtools index '${sampleName}.bam'
        """
}

params.bam = null

workflow {
    output = samtools_fixmate( params.bam )
    emit:
        output
}
