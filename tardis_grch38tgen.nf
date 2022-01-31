nextflow.enable.dsl=2

include { map_fastq } from "./map_fastq_bwa_mem_grch38tgen.nf"
include { merge_bams } from "./merge_bams_samtools.nf"

params.fastq1 = null
params.fastq2 = null
params.rg = null
params.sample = null

fastq1 = Channel.fromPath( params.fastq1 )
fastq2 = Channel.fromPath( params.fastq2 )

workflow {
    unmerged_bams = map_fastq( fastq1,
                               fastq2,
                               params.rg,
                               params.sample
                             ).collect()
    merged_bam = merge_bams( unmerged_bams,
                             params.sample )
}

