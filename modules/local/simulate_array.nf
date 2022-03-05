process SIMULATE_ARRAY {

publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(chr), path(array_file), path(seq_file)

    output:
    tuple val(array_file.baseName), path("*vcf.gz"), emit: sim_out

    shell:
    """
    sim_file="${array_file.baseName}.chr${chr}.vcf.gz"
    tab_file="regions.txt"
    tab_file_sorted="regions.sorted.txt"

    while read -r firstCol chrCol posCol remainder
      do
      if [ "${chr}" = "\$chrCol" ]; then
      echo -e "${chr}\t\$posCol" >> \$tab_file
      fi
    done < ${array_file}

    sort -k1b,1 -k2n,2 -o \$tab_file_sorted \$tab_file
    rm \$tab_file

    tabix ${seq_file}
    bcftools view -T \$tab_file_sorted ${seq_file} | bgzip -c > \$sim_file
    tabix \$sim_file
    rm \$tab_file_sorted
    """
}
