process CALCULATE_RSQ {

    publishDir "${params.pubDir}/rsq", mode: 'copy', pattern: '*aggRSquare'

    input:
    tuple val(chr), path(dosage_data), path(sequence_data)

    output:
    path("*aggRSquare"), emit: agg_rsquare


    """
    aggRSquare -v ${sequence_data} -i ${dosage_data} -o ${sequence_data.baseName} --d
    sed -i '/^##/d' ${sequence_data.baseName}.aggRSquare
    """
}
