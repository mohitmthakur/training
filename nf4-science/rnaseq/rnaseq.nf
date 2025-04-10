#!/usr/bin/env nextflow

// Module INCLUDE statements
include { FASTQC } from './modules/fastqc/main.nf'
include { TRIM_GALORE } from './modules/trim_galore/main.nf'
include { HISAT2_ALIGN } from './modules/hisat2/align/main.nf'
include { SAMTOOLS_INDEX } from './modules/samtools/index/main.nf'
include { GATK_CREATE_SEQ_DICT } from './modules/gatk/create_seq_dict/main.nf'
include { SAMTOOLS_FAIDX } from './modules/samtools/faidx/main.nf'
// include { SAMTOOLS_IDXSTATS } from './modules/samtools/idxstats/main.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk/haplotypecaller/main.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk/jointgenotyping/main.nf'
include { BCFTOOLS_CALL } from './modules/staphb/bcftools/call/main.nf'

/*
 * Pipeline parameters
 */
// Primary input
params.input_csv        = "data/paired-end.csv"
params.hisat2_index_zip = "data/genome_index.tar.gz"
params.reference_fa     = "data/genome.fa"
params.interval_list    = "data/intervals.bed"

// Output directory
params.outdir           = "results"

workflow {

    // Create input channels
    read_ch = Channel.fromPath(params.input_csv)
        .splitCsv(header: true)
        .map { row -> [row.sample_id, [file(row.fastq_1), file(row.fastq_2)]] } // Channel is now a list of paired-end tuples
        // .view()

    reference_fa = file(params.reference_fa)

    interval_ch = file(params.interval_list)

    // Initial Quality Control -> fastqc
    FASTQC(read_ch)

    // Trim Reads, Second Quality Control -> fastqc, fastq
    TRIM_GALORE(read_ch)

    // Align the Reads to the Reference Genome -> bam
    HISAT2_ALIGN(TRIM_GALORE.out.trimmed_reads, file(params.hisat2_index_zip))

    // Sort and Index the bam file
    SAMTOOLS_INDEX(HISAT2_ALIGN.out.bam)

    // TODO: module broken for now.
    // Generate index stats for bam files
    // SAMTOOLS_IDXSTATS(SAMTOOLS_INDEX.out.bam)

    // Create a reference dict file
    GATK_CREATE_SEQ_DICT(reference_fa)

    // Create a reference index file
    SAMTOOLS_FAIDX(reference_fa)

    BCFTOOLS_CALL(SAMTOOLS_INDEX.out.bam, reference_fa)
    // GATK_HAPLOTYPECALLER(SAMTOOLS_INDEX.out.bam, reference_fa_ch, SAMTOOLS_FAIDX.out.ref_index, GATK_CREATE_SEQ_DICT.out.ref_dict, interval_ch)
}
