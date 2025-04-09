#!/usr/bin/env nextflow

process HISAT2_ALIGN {

    container "community.wave.seqera.io/library/hisat2_samtools:5e49f68a37dc010e"
    publishDir "results/aligned", mode: 'copy'

    input:
    tuple val(sampleId), file(reads) // reads is a tuple for paired end
    path index_zip

    output:
    path "${sampleId}.bam", emit: bam // Should be trimmed, but generic for other cases
    path "${sampleId}.hisat2.log", emit: log // Should be trimmed, but generic for other cases

    script:
    """
    tar -xzvf ${index_zip}

    hisat2 -x ${index_zip.simpleName} -1 ${reads[0]} -2 ${reads[1]} \
        --new-summary --summary-file ${sampleId}.hisat2.log \
        | samtools view -bS -o ${sampleId}.bam
    """
}
