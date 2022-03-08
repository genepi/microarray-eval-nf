process FILTER_SEQUENCE_DATA {

//publishDir "${params.outdir}/${array_name}", mode: 'copy'

    input:
    path(sequence_data)

    output:
    path("*filtered.vcf.gz"), emit: sequence_data_filtered


    """
    bcftools view --max-alleles 2 --exclude-types indels ${sequence_data} | bgzip -c >  ${sequence_data.baseName}.filtered.vcf.gz
    """
}
