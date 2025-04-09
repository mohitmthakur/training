#!/usr/bin/env nextflow
//include { convertToUpper } from './solutions/4-hello-modules/modules/convertToUpper.nf'
//include { convertToUpper } from './solutions/4-hello-modules/modules/convertToUpper.nf'

/*
 * Emit greeting to a file
 */
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "${greeting}-output.txt"

    script:
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}

/*
 * Convert the greeting to uppercase
 */
process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    script:
    """
    cat ${input_file} | tr '[a-z]' '[A-Z]' > 'UPPER-${input_file}'
    """
}

/*
 * Collect uppercase greetings into a single output file
 */
process collectGreetings {

    publishDir 'results', mode: 'copy'

    input:
        path input_files
        val batch_name

    output:
        path "COLLECTED-${batch_name}-output.txt" , emit: outfile
        val count_greetings , emit: count

    script:
        count_greetings = input_files.size()
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
}

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

    // Emit greeting to a file
    sayHello(greeting_ch)

    // Convert the greeting to uppercase
    convertToUpper(sayHello.out)

    // convertToUpper.out.view { greeting -> "Before collecting: ${greeting}" }
    // convertToUpper.out.collect().view { greeting -> "After collecting: ${greeting}" }

    // Collect greetings into a single output file
    collectGreetings(convertToUpper.out.collect(), params.batch)

    collectGreetings.out.count.view { num_greetings -> "There were ${num_greetings} in this batch"}
    // OR
    // greeting_ch.count().view()
}
