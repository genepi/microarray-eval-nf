process FILTER_SEQUENCE_DATA {

    input:
    path(sequence_data)

    output:
    path("*filtered.vcf.gz"), emit: sequence_data_filtered


    """
    bcftools view --max-alleles 2 --exclude-types indels ${sequence_data} -Oz -o ${sequence_data.baseName}.filtered.vcf.gz
    """
}
