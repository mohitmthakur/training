#!/usr/bin/env nextflow

process TRIM_GALORE {

    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"
    publishDir "results/trimmed", mode: 'copy'

    input:
    path reads

    output:
    path "${reads.simpleName}_trimmed_fastqc.{zip,html}", emit: fastq_reports
    path "${reads.simpleName}_trimmed.fq.gz", emit: trimmed_reads
    path "${reads}_trimming_report.txt", emit: trimmed_reports

    script:
    """
    trim_galore --fastqc ${reads}
    """
}
