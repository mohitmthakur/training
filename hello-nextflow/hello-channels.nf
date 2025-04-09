#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "${greeting}-output.txt"
        // Double quotes, not single quotes are critical here

    script:
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}

/*
 * Pipeline parameters
 */
params.greeting = 'greetings.csv'

workflow {

    // Create an array to then be passed to a new channel
    greeting_array = ['Hello', 'Bonjour', 'Konichiwa']

    // Declare a channel for the required greeting input parameter
    // greeting_ch = Channel.of('Hello', 'Bonjour', 'Konichiwa') // Original, hard-coded way
    // greeting_ch = Channel.of(greeting_array)
    // .view { greeting -> "Before flatten: $greeting" }
    // .flatten()
    // .view { greeting -> "After flatten: $greeting" }
    // OR
    // greeting_ch = Channel.fromList(greeting_array)

    // Declare a channel for the required greeting using a file
    greeting_ch = Channel.fromPath(params.greeting)
        .view { csv -> "Before splitCsv: $csv:" }
        .splitCsv() // Make a file path get read in
        .view { csv -> "After splitCsv: $csv" }
        .map { item -> item[0] } // For each item in the channel, take the first element of any item it contains (in this case, the only)
        .view { csv -> "After map: $csv" }

    // emit a greeting
    sayHello(greeting_ch)
}
