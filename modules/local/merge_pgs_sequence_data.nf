process MERGE_PGS_SEQUENCE_DATA {

  publishDir "$params.outdir/scores", mode: 'copy'

  input:
    tuple val(chip), path(score_chunks), path(report_chunks)

  output:
    path "${params.project}.sequence.scores.txt", emit: scores_data
    path "${params.project}.sequence.scores.info", emit: scores_info

  """
  pgs-calc merge-score ${score_chunks} \
    --out ${params.project}.sequence.scores.txt

  pgs-calc merge-info ${report_chunks} \
    --out ${params.project}.sequence.scores.info

  """

}
