nextflow.enable.dsl=2

import org.yaml.snakeyaml.Yaml

params.fastq_pairs = null
params.rg = null
params.sample = null
params.reference_fa = null
params.reference_fa_ann = null
params.reference_fa_amb = null
params.reference_fa_bwt = null
params.reference_fa_pac = null
params.reference_fa_sa = null
params.reference_fa_fai = null
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
               params.reference_fa,
               params.reference_fa_ann,
               params.reference_fa_amb,
               params.reference_fa_bwt,
               params.reference_fa_pac,
               params.reference_fa_sa )

    merge_bams( map_fastq.out.bam.collect(),
                params.sample )

    Yaml parser = new Yaml()
    gatk_haplotypecaller_intervals = parser.load((params.gatk_haplotypecaller_intervals as File).text)

    for (interval in gatk_haplotypecaller_intervals.calling_intervals) {
        intervals = interval.collect { ' -L "' + it.contig + ':' + it.start + '-' + it.stop + '" ' }
    }
    
    output = call_variants_gatk_haplotypecaller( merge_bams.out.bam,
                                        params.reference_fa,
                                        params.reference_fa_fai,
                                        params.reference_dict,
                                        intervals )

    emit:
        output
}
