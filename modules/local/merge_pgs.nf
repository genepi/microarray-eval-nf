process MERGE_PGS {

  publishDir "$params.outdir/scores", mode: 'copy'

  input:
    tuple val(chip), path(score_chunks), path(report_chunks)

  output:
    path "${params.project}.${chip}.scores.txt", emit: scores_data
    path "${params.project}.${chip}.scores.info", emit: scores_info

  """
  pgs-calc merge-score ${score_chunks} \
    --out ${params.project}.${chip}.scores.txt

  pgs-calc merge-info ${report_chunks} \
    --out ${params.project}.${chip}.scores.info

  """

}
