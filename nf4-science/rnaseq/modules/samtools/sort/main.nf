/*
 * Generate BAM index file
 */
process SAMTOOLS_SORT {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
        path input_bam

    output:
        path "*.sorted.bam" , emit: bam

    script:
    def sorted_bam = input_bam.replace(".bam", ".sorted.bam")
    """
    samtools sort ${input_bam} -o ${sorted_bam}
    """
}
