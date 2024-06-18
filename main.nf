/*
========================================================================================
    genepi/microarray-eval-nf
========================================================================================
    Github : https://github.com/genepi/microarray-eval-nf
    Author: Sebastian Schönherr, Lukas Forer, Martin Eberle
    ---------------------------
*/

nextflow.enable.dsl = 2

if(params.outdir == null) {
  params.pubDir = "output/${params.project}"
} else {
  params.pubDir = params.outdir
}

include { SIMULATION } from './workflows/simulation'
include { RSQ } from './workflows/rsq'

workflow {
    
    switch (params.workflow_name) {

        case 'simulate':
            SIMULATION ()
            break

        case 'r2':
             RSQ ()
             break

        default:
             error "Unknown workflow: ${params.workflow_name}"
             break

    }
    
}
