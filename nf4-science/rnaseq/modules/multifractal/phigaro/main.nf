/*
 * Generate the variant calls for bam files
 */
process BCFTOOLS_VIEW {

    container "staphb/bcftools"
    publishDir "${params.outdir}/vcf", mode: 'copy'

    input:
        tuple val(sampleId), path(input_bam), path(input_bam_index)
        path ref_fasta
        path interval_list // To exclude, e.g. phages

    output:
        path "${sampleId}.bcf"  , emit: bcf

    script:
    """
    bcftools mpileup -Ou -f ${ref_fasta} ${input_bam} | bcftools call -m -v -T ^${interval_list} -Ob -o ${sampleId}.bcf
    """
}
