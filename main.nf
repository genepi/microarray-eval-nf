#!/usr/bin/env nextflow
/*
========================================================================================
    seppinho/microarray-eval-nf
========================================================================================
    Github : https://github.com/seppinho/microarray-eval-nf
    Author: Sebastian Schönherr, Lukas Forer, Martin Eberle
    ---------------------------
*/

nextflow.enable.dsl = 2

switch (params.workflow_name) {
    case 'simulate':
        include { ARRAY_SIMULATION } from './workflows/chip_simulation'
        workflow {
            ARRAY_SIMULATION ()
        }
        break
    default:
        error "Unknown workflow: ${params.workflow_name}"
        break
}
