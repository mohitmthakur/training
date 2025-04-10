#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

include { SPLIT_LETTERS } from './modules/split_letters'
include { CONVERT_TO_UPPER } from './modules/convert_to_upper/main.nf'

workflow{

    greeting_ch = Channel.of(params.greeting)

    letters_ch = SPLIT_LETTERS(greeting_ch)
    results_ch = CONVERT_TO_UPPER(letters_ch.flatten())
    results_ch.view{ it }
}
