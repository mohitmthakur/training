#!/usr/bin/env nextflow
include { sayHello } from './modules/local/sayHello.nf'
include { convertToUpper } from './modules/local/convertToUpper'
include { collectGreetings } from './modules/local/collectGreetings'

/*
 * Pipeline parameters
 */
params.greeting = 'greetings.csv'
params.batch = 'test-batch'

workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
                        .splitCsv()
                        .map { line -> line[0] }

    // emit a greeting
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)

    // collect all the greetings into one file
    collectGreetings(convertToUpper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collectGreetings.out.count.view { "There were $it greetings in this batch" }
}
