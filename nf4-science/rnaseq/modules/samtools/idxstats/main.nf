/*
 * Generate BAM index file
 */
process SAMTOOLS_IDXSTATS {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    publishDir "${params.outdir}/bam/idxstats", mode: 'copy'

    input:
        tuple val(sampleId), path(input_bam), path(input_bam_index)

    output:
        path "*.sorted.bam" , emit: bam_index_stats

    script:
    def sorted_bam = input_bam.replace(".bam", ".sorted.bam")
    """
    samtools sort ${input_bam} -o ${sorted_bam}
    """
}
