/*
 * Generate QC results for fastq files
 */
process FASTQC {

    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    // path reads
    tuple val(sampleId), file(reads)

    output:
    path "*_fastqc.zip", emit: zip
    path "*_fastqc.html", emit: html

    script:
    """
    fastqc ${reads}
    """
}
