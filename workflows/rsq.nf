include { LIFT_OVER } from '../modules/local/lift_over'
include { CALCULATE_RSQ } from '../modules/local/calculate_rsq'

workflow RSQ {

    imputed_data  = channel.fromPath(params.imputed_data, checkIfExists: true)
    sequence_data = channel.fromPath(params.sequence_data, checkIfExists: true)

    imputed_data
        .map { sequence_data -> tuple(getChromosome(sequence_data), sequence_data) }
        .set { imputed_data_filtered }
        
    sequence_data
        .map { imputed_data -> tuple(getChromosome(imputed_data), imputed_data) }
        .set { sequence_data_filtered }

    // combine with sequence data
    r2_input_data_combined = imputed_data_filtered.combine(sequence_data_filtered, by:0)

    // lift sequence data to allow comparision with aggRSquare
    if (params.imputation_build != params.sequence_build) {
        LIFT_OVER(r2_input_data_combined)
        r2_input_data_lifted = LIFT_OVER.out.sequence_data_lifted
    } else {
        r2_input_data_lifted = r2_input_data_combined
    }

    CALCULATE_RSQ ( r2_input_data_lifted )

}

def getChromosome(seq_file) {
    return ((seq_file.baseName =~ /[cC][hH][rR](\d{1,2}|[xX]|MT)/)[0][1])
}
