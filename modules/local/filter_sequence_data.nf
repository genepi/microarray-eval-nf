process FILTER_SEQUENCE_DATA {

    input:
    path(sequence_data)
    path sample_file
    output:
    path("*filtered.vcf.gz"), emit: sequence_data_filtered


    """
    bcftools view --max-alleles 2 --exclude-types indels ${sequence_data} -Oz -o ${sequence_data.baseName}.filtered.vcf.gz

    # select subset of samples
    if [[ -n "$sample_file" ]]
    then
      bcftools view -S $sample_file ${sequence_data.baseName}.filtered.vcf.gz | bgzip -c > tmp_${sequence_data.baseName}.filtered.vcf.gz
      mv tmp_${sequence_data.baseName}.filtered.vcf.gz ${sequence_data.baseName}.filtered.vcf.gz
    fi

    """
}
