process CALCULATE_PGS {

  input:
    tuple val(chip), path(vcf_file)
    path scores

  output:
    tuple val(chip), path("${chip}.${vcf_file.baseName}.scores.txt"), path("${chip}.${vcf_file.baseName}.scores.info"), emit: scores_chunks
    path "*.log"

  """
  pgs-calc apply ${vcf_file} \
    --ref ${scores.join(',')} \
    --out ${chip}.${vcf_file.baseName}.scores.txt \
    --info ${chip}.${vcf_file.baseName}.scores.info \
    --genotypes DS \
    --no-ansi > ${chip}.${vcf_file.baseName}.scores.log
  """

}
