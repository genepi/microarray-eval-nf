process CALCULATE_PGS_SEQUENCE_DATA {

  input:
    path(vcf_file)
    path scores

  output:
    tuple val("sequence"), path("sequence.${vcf_file.baseName}.scores.txt"),path("sequence.${vcf_file.baseName}.scores.info"), emit: scores_chunks
    path "*.log"

  """
  pgs-calc apply ${vcf_file} \
    --ref ${scores.join(',')} \
    --out sequence.${vcf_file.baseName}.scores.txt \
    --info sequence.${vcf_file.baseName}.scores.info \
    --genotypes GT \
    --no-ansi > sequence.${vcf_file.baseName}.scores.log
  """

}
