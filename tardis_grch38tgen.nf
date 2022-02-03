nextflow.enable.dsl=2

params.fastq_pairs = null
params.rg = null
params.sample = null
params.workflow_publish_dir = ""

workflow_publish_dir = params.workflow_publish_dir

include { map_fastq } from "./map_fastq_bwa_mem_grch38tgen.nf"
include { merge_bams } from "./merge_bams_samtools.nf" params([*:params, "publish_dir": workflow_publish_dir]) 

fastq_pairs = Channel.fromFilePairs( params.fastq_pairs )

workflow {
    map_fastq( fastq_pairs,
               params.rg,
               params.sample )
    merge_bams( map_fastq.out.bam.collect(),
                params.sample )
}

