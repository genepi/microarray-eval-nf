process CALCULATE_IMPUTATION_ACCURACY {

publishDir "${params.outdir}/${array_name}/aggRSquare", mode: 'copy', pattern: '*aggRSquare'

    input:
    tuple val(chr), val(array_name), path(dosage_data), path(sequence_data)

    output:
    tuple val(array_name), path("*.RSquare"), emit: r2_data_out
    path("*aggRSquare"), emit: agg_rsquare


    """
    if(${params.apply_mis_fix})
     then
      # WORKAROUND: dosage file must be gunzip/bgzip that aggRSquare can read it (related to how MIS2 splits files with bcftools )
      cp ${dosage_data} ${dosage_data.baseName}.tmp.vcf.gz
      gunzip ${dosage_data.baseName}.tmp.vcf.gz
      bgzip  ${dosage_data.baseName}.tmp.vcf
      aggRSquare -v ${sequence_data} -i ${dosage_data.baseName}.tmp.vcf.gz -o ${array_name}_${sequence_data.baseName} --d
    else
      aggRSquare -v ${sequence_data} -i ${dosage_data} -o ${array_name}_${sequence_data.baseName} --d
    fi
    """
}
