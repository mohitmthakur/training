/*
 * Create a sequence dictionary from a fasta reference
 */
process GATK_CREATE_SEQ_DICT {

    container 'community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867'

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
        path ref_fasta

    output:
        path "*.dict" , emit: ref_dict

    script:
    """
    gatk CreateSequenceDictionary -R ${ref_fasta}
    """
}
