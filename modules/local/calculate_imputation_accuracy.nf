process CALCULATE_IMPUTATION_ACCURACY {

//publishDir "${params.outdir}/${array_name}", mode: 'copy'

    input:
    tuple val(array_name), path(dosage_data), path(sequence_data), val(chr)

    output:
    tuple val(array_name), path("*.RSquare"), emit: r2_data_out
    //tuple path("*aggRSquare"), emit: test


    """
    # WORKAROUND: dosage file must be gunzip/bgzip that aggRSquare can read it (related to how MIS2 splits files with bcftools )
    cp ${dosage_data} ${dosage_data.baseName}.tmp.vcf.gz
    gunzip ${dosage_data.baseName}.tmp.vcf.gz
    bgzip  ${dosage_data.baseName}.tmp.vcf
    aggRSquare -v ${sequence_data} -i ${dosage_data.baseName}.tmp.vcf.gz -o ${array_name}_${sequence_data.baseName} --d
    """
}
