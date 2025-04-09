#!/usr/bin/env nextflow

// Module INCLUDE statements
include { FASTQC_PE } from './modules/fastqc_pe.nf'
include { TRIM_GALORE_PE } from './modules/trim_galore_pe.nf'
include { HISAT2_ALIGN_PE } from './modules/hisat2_align_pe.nf'

/*
 * Pipeline parameters
 */

// Primary input
params.input_csv        = "data/paired-end.csv"
params.hisat2_index_zip = "data/genome_index.tar.gz"

workflow {

    // Create input channels
    read_ch = Channel.fromPath(params.input_csv)
        .splitCsv(header: true)
        .map { row -> [row.sample_id, [file(row.fastq_1), file(row.fastq_2)]] } // Channel is now a list of paired-end tuples
        .view()

    // Initial Quality Control
    FASTQC_PE(read_ch)

    // Trim Reads, Second Quality Control
    TRIM_GALORE_PE(read_ch)

    // Align the Reads to the Reference Genome
    HISAT2_ALIGN_PE(TRIM_GALORE_PE.out.trimmed_reads, file(params.hisat2_index_zip))
}
