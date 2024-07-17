process CALCULATE_RSQ {

    publishDir "${params.pubDir}/rsq", mode: 'copy', pattern: '*aggRSquare'

    input:
    tuple val(chr), path(dosage_data), path(sequence_data)

    output:
    path("*aggRSquare"), emit: agg_rsquare


    """
    aggRSquare \
        --validation ${sequence_data} \
        --imputation ${dosage_data} \
        --output ${sequence_data.baseName} \
        --detail \
        --imputationFormat ${params.rsq_imputation_format} \
        --validationFormat ${params.rsq_validation_format}

    sed -i '/^##/d' ${sequence_data.baseName}.aggRSquare
    """
}
