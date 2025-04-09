#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */

// Primary input (file of input files, one per line)
params.reads_bam = "${projectDir}/data/sample_bams.txt"

// Primary input names (housekeeping names for output directories, files)
params.cohort_name = "family-trio"

// Output directory
params.outdir = "results_genomics"

// Accessory files
params.reference        = "${projectDir}/data/ref/ref.fasta"
params.reference_index  = "${projectDir}/data/ref/ref.fasta.fai"
params.reference_dict   = "${projectDir}/data/ref/ref.dict"
params.intervals        = "${projectDir}/data/ref/intervals.bed"

/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    publishDir params.outdir, mode: 'symlink'

    input:
        path input_bam

    output:
        tuple path(input_bam), path("${input_bam}.bai") , emit: bam

    script:
    """
    samtools index '$input_bam'
    """
}

/*
 * Call variants with GATK HaplotypeCaller
 */
process GATK_HAPLOTYPECALLER {

    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"

    publishDir params.outdir, mode: 'symlink'

    input:
        tuple path(input_bam), path(input_bam_index)
        path ref_fasta
        path ref_index
        path ref_dict
        path interval_list

    output:
        path "${input_bam}.vcf"     , emit: vcf
        path "${input_bam}.vcf.idx" , emit: idx

    script:
    """
    gatk HaplotypeCaller \
        -R ${ref_fasta} \
        -I ${input_bam} \
        -O ${input_bam}.g.vcf \
        -L ${interval_list}
    """
}

/*
 * Call variants with GATK HaplotypeCaller
 */
process GATK_JOINT_HAPLOTYPECALLER {

    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"

    publishDir params.outdir, mode: 'symlink'

    input:
        tuple path(input_bam), path(input_bam_index)
        path ref_fasta
        path ref_index
        path ref_dict
        path interval_list

    output:
        path "${input_bam}.g.vcf"     , emit: gvcf
        path "${input_bam}.g.vcf.idx" , emit: idx

    script:
    """
    gatk HaplotypeCaller \
        -R ${ref_fasta} \
        -I ${input_bam} \
        -O ${input_bam}.g.vcf \
        -L ${interval_list} \
        -ERC GVCF
    """
}


process GATK_JOINTGENOTYPING {

    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"

    publishDir params.outdir, mode: 'copy'

    input:
        path all_gvcfs // This will be a collected channel of all vcfs
        path all_idxs // This will be a collected channel of all vcf idxs
        path interval_list
        val cohort_name // For now, include an explicit parameter for the joint name
        path ref_fasta
        path ref_index
        path ref_dict

    output:
        // path "${cohort_name}_gdb"   , emit: gdb
        path "${cohort_name}.joint.vcf"     , emit: vcf
        path "${cohort_name}.joint.vcf.idx" , emit: idx

    script:
    def gvcfs_line = all_gvcfs.collect { gvcf -> "-V ${gvcf}" }.join(' ') // String manipulation to put a -V between each entry, because gatk does it weird
    """
    gatk GenomicsDBImport \
        ${gvcfs_line} \
        -L ${interval_list} \
        --genomicsdb-workspace-path ${cohort_name}_gdb

    gatk GenotypeGVCFs \
        -R ${ref_fasta} \
        -V gendb://${cohort_name}_gdb \
        -L ${interval_list} \
        -O ${cohort_name}.joint.vcf
    """
}
workflow {

    // Create input channel from a text file listing input file paths
    reads_ch = Channel.fromPath(params.reads_bam).splitText()

    // Load the file paths for the accessory files (reference and intervals)
    ref_file        = file(params.reference)
    ref_index_file  = file(params.reference_index)
    ref_dict_file   = file(params.reference_dict)
    intervals_file  = file(params.intervals)

    // Create index file for input BAM file
    SAMTOOLS_INDEX(reads_ch)

    // Call variants from the indexed BAM file
    GATK_JOINT_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out.bam,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    GATK_JOINTGENOTYPING(
        GATK_JOINT_HAPLOTYPECALLER.out.gvcf.collect(),
        GATK_JOINT_HAPLOTYPECALLER.out.idx.collect(),
        intervals_file,
        params.cohort_name,
        ref_file,
        ref_index_file,
        ref_dict_file,
    )
}
