nextflow.enable.dsl=2

import org.yaml.snakeyaml.Yaml

params.fastq_pairs = null
params.rg = null
params.sample = null
params.reference = null
params.reference_ann = null
params.reference_amb = null
params.reference_bwt = null
params.reference_pac = null
params.reference_sa = null
params.reference_fai = null
params.reference_dict = null
params.gatk_haplotypecaller_intervals = null
params.workflow_publish_dir = ""

workflow_publish_dir = params.workflow_publish_dir

include { map_fastq } from "./map_fastq_bwa_mem.nf"
include { merge_bams } from "./merge_bams_samtools.nf"
include { call_variants_gatk_haplotypecaller } from "./call_variants_gatk_haplotypecaller.nf" params([*:params, "publish_dir": workflow_publish_dir])

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

    Yaml parser = new Yaml()
    gatk_haplotypecaller_intervals = parser.load((params.gatk_haplotypecaller_intervals as File).text)

    for (interval in gatk_haplotypecaller_intervals.calling_intervals) {
        intervals = interval.collect { ' -L "' + it.contig + ':' + it.start + '-' + it.stop + '" ' }
    }
    
    call_variants_gatk_haplotypecaller( merge_bams.out.bam,
                                        params.reference,
                                        params.reference_fai,
                                        params.reference_dict,
                                        intervals )
}
