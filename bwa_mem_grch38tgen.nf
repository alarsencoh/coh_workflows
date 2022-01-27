nextflow.enable.dsl=2

process bwa_mem {
    input:
        file fastq1
        file fastq2
        val rg
        val sample
    output:
        file "${sample}.bam"

    container "ghcr.io/coh-apps/coh_app_bwa-0.7.17.grch38tgen:skylake"
    cpus 4
    memory '15 GB'

    script:
        """
            bwa mem -v 3 -Y -K 10000000 -t 4 -R "${rg}" \
            /database/GRCh38tgen_decoy_alts_hla.fa \
            "${fastq1}" "${fastq2}" \
            > "${sample}.bam"
        """
}

params.fastq1 = null
params.fastq2 = null
params.rg = null
params.sample = null

workflow {
    output = bwa_mem( params.fastq1,
                      params.fastq2,
                      params.rg,
                      params.sample )
    emit:
        output
}
