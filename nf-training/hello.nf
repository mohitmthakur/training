#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

process SPLIT_LETTERS {
    input:
    val x

    output:
    path 'chunk_*'

    script:
    """
    printf '$x' | split -b 6 - chunk_
    """
}

process CONVERT_TO_UPPER {
    input:
    path y

    output:
    stdout

    script:
    """
    cat $y | tr '[a-z]' '[A-Z]'
    """
}

workflow {

    greeting_ch = Channel.of(params.greeting)

    letters_ch = SPLIT_LETTERS(greeting_ch)
    results_ch = CONVERT_TO_UPPER(letters_ch.flatten())
    results_ch.view{ it }
}
