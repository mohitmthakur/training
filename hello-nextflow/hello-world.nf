#!/usr/bin/env nextflow

/*
 * Overview
 */
// Use echo to print 'Hello World!' to a file

/*
 * Processes
 */
process sayHello {

    publishDir 'results', mode: 'copy'
    // Default mode is 'symlink', but symlinks break when running `nextflow clean`

    input:
        val greeting
        // 'greeting' is now a pipeline parameter, which means it is required as an argument for sayHello()

    output:
        path "output.txt"

    script:
    """
    echo '$greeting' > output.txt
    """
}

/*
 * Parameters
 */
params.greeting = 'Holà mundo!'
// Default; override this during runtime with --greeting
// parameter priority: nextflow.config (projectDir) -> nextflow.config (launchDir) -> -c <config_file> -> nextflow run hello-world.nf --<parameter>

/*
 * Main workflow
 */
workflow {

    // emit a greeting
    sayHello(params.greeting)
    // Accepting this as a parameter in the workflow allows customization during runtime (--greeting) or in param file.

}
