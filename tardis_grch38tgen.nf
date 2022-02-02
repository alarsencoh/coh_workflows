nextflow.enable.dsl=2

include { map_fastq } from "./map_fastq_bwa_mem_grch38tgen.nf"
include { merge_bams } from "./merge_bams_samtools.nf"

params.fastq_pairs = null
params.rg = null
params.sample = null

fastq_pairs = Channel.fromFilePairs( params.fastq_pairs )

workflow {
    unmerged_bams = map_fastq( fastq_pairs,
                               params.rg,
                               params.sample
                             ).collect()
    merged_bam = merge_bams( unmerged_bams,
                             params.sample )
}

