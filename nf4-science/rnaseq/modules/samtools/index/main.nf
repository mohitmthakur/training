/*
 * Sort BAM file and generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
        tuple val(sampleId), path(input_bam)

    output:
        tuple val(sampleId), path("*.bam"), path("*.bam.bai") , emit: bam

    script:
    """
    samtools sort ${input_bam} -o ${sampleId}.sorted.bam && samtools index ${sampleId}.sorted.bam
    """
}
