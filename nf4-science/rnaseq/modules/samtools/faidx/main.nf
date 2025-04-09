/*
 * Generate fasta index file
 */
process SAMTOOLS_FAIDX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
        path ref_fasta

    output:
        path "*.fai" , emit: ref_index

    script:
    """
    samtools faidx ${ref_fasta}
    """
}
