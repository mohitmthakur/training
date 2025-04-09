#!/usr/bin/env nextflow

// Module INCLUDE statements
include { FASTQC } from './modules/fastqc/main.nf'
include { TRIM_GALORE } from './modules/trim_galore/main.nf'
include { HISAT2_ALIGN } from './modules/hisat2/align/main.nf'

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
    FASTQC(read_ch)

    // Trim Reads, Second Quality Control
    TRIM_GALORE(read_ch)

    // Align the Reads to the Reference Genome
    HISAT2_ALIGN(TRIM_GALORE.out.trimmed_reads, file(params.hisat2_index_zip))
}
