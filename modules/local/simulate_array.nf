process SIMULATE_ARRAY {

//publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(chr), path(strand_data), path(sequence_data)

    output:
    tuple val(strand_data.baseName), path("*vcf.gz"), val(chr), path(sequence_data), emit: array_data

    shell:
    '''
    sim_file="!{strand_data.baseName}.chr!{chr}.vcf.gz"
    tab_file="regions.txt"
    tab_file_sorted="regions.sorted.txt"

    while read -r firstCol chrCol posCol remainder
      do
        if [ "!{chr}" = "$chrCol" ]; then
            if [ "!{params.imputation_build}" = "hg38" ]; then
              echo -e "chr!{chr}\t$posCol" >> $tab_file
            else
              echo -e "!{chr}\t$posCol" >> $tab_file
            fi
        fi
    done < !{strand_data}

    sort -k1b,1 -k2n,2 -o $tab_file $tab_file

    tabix -f !{sequence_data}

    if(!{params.remove_seq_filters})
     then
      bcftools view -T $tab_file !{sequence_data} -Oz -o tmp.vcf.gz
      bcftools annotate tmp.vcf.gz --remove FILTER -Oz -o $sim_file
      rm tmp.vcf.gz
    else
      bcftools view -T $tab_file !{sequence_data} -Oz -o $sim_file
    fi
    tabix $sim_file
    '''
}
