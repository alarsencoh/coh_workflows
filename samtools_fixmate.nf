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
            samtools fixmate --threads 4 -m '${bam}' - | \
            samtools sort -l 2 -m 2G --threads 4 --output-fmt BAM -o 'temp.bam'
        """
}

params.bam = null

workflow {
    output = samtools_fixmate( params.bam )
    emit:
        output
}
