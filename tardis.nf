nextflow.enable.dsl=2

params.fastq_pairs = null
params.rg = null
params.sample = null
params.reference = null
params.reference_ann = null
params.reference_amb = null
params.reference_bwt = null
params.reference_pac = null
params.reference_sa = null
params.workflow_publish_dir = ""

workflow_publish_dir = params.workflow_publish_dir

include { map_fastq } from "./map_fastq_bwa_mem.nf"
include { merge_bams } from "./merge_bams_samtools.nf" params([*:params, "publish_dir": workflow_publish_dir]) 

fastq_pairs = Channel.fromFilePairs( params.fastq_pairs )

workflow {
    map_fastq( fastq_pairs,
               params.rg,
               params.sample,
               params.reference,
               params.reference_ann,
               params.reference_amb,
               params.reference_bwt,
               params.reference_pac,
               params.reference_sa )
    merge_bams( map_fastq.out.bam.collect(),
                params.sample )
}

