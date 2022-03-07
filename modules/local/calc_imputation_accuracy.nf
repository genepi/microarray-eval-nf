process CALC_IMPUTATION_ACCURACY {

//publishDir "${params.outdir}/${array_name}", mode: 'copy'

    input:
    tuple val(array_name), path(array), path(seq), val(chr)

    output:
    tuple val(array_name), path("*.RSquare"), emit: r2_data_out


    """
    aggRSquare -v ${seq} -i ${array} -o ${array_name}_${seq.baseName} --d
    """
}
