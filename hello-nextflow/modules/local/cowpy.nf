#!/usr/bin/env nextflow

/*
 * Use cowpy (container) to generate ASCII art
 */
process cowpy {

    container 'community.wave.seqera.io/library/cowpy:1.1.5--3db457ae1977a273' // Also needed to modify config file to enable docker
    conda 'conda-forge::cowpy==1.1.5'

    publishDir 'results', mode: 'copy'

    input:
        path input_file // greetings.csv
        val character // "turtle", "tux". "turkey". etc. See cowpy -l.

    output:
        path "cowpy-${input_file}" // Don't forget double quotes!

    script:
    """
    cat ${input_file} | cowpy -c "${character}" > cowpy-${input_file}
    """
}
