process SIMULATE_ARRAY {

    input:
    tuple val(chr), path(strand_data), path(sequence_data)
    path sample_file

    output:
    tuple val(strand_data.baseName), path("*vcf.gz"), val(chr), emit: array_data

    script:
    def sim_file="${strand_data.baseName}.chr${chr}.vcf.gz"
    def tab_file="regions.txt"
    def tab_file_sorted="regions.sorted.txt"

    """
    while read -r firstCol chrCol posCol remainder
      do
        if [ "${chr}" = "\$chrCol" ]; then
            if [ "${params.sequence_build}" = "hg38" ]; then
              echo -e "chr${chr}\t\$posCol" >> $tab_file
            else
              echo -e "${chr}\t\$posCol" >> $tab_file
            fi
        fi
    done < ${strand_data}

    sort -k1b,1 -k2n,2 -o $tab_file_sorted $tab_file

    tabix -f ${sequence_data}

   #remove filters from input otherwise no imputation can be started for these SNPs
    if [[ "${params.remove_seq_filters}" = true ]]
    then
      bcftools view -T $tab_file_sorted ${sequence_data} -Oz -o tmp.vcf.gz
      bcftools annotate tmp.vcf.gz --remove FILTER -Oz -o $sim_file
      rm tmp.vcf.gz
    else
      bcftools view -T $tab_file_sorted ${sequence_data} -Oz -o $sim_file
    fi

    # select only every Xth-line from chip
    if (( ${params.chip_line_selection} != 0 ))
    then
      bcftools view -h $sim_file | bgzip -c > header.vcf.gz
      bcftools view -H $sim_file | awk 'NR % ${params.chip_line_selection} == 0' | bgzip -c > tmp_$sim_file
      cat header.vcf.gz tmp_$sim_file  > $sim_file
      rm header.vcf.gz tmp_$sim_file 
    fi


    # select subset of samples
    if [[ -n "${params.sample_file}" ]]
    then
      bcftools view -S $sample_file $sim_file | bgzip -c > tmp_$sim_file
      mv tmp_$sim_file $sim_file
    fi

    tabix $sim_file

    """
}
