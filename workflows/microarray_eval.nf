

if (!params.imputation_token) {
   exit 1, "[Pipeline error] Parameter 'token' is not set in the pipeline!\n"
}


include { SIMULATE_ARRAY } from '../modules/local/simulate_array'
include { IMPUTE_ARRAY } from '../modules/local/impute_array'
include { CALC_IMPUTATION_ACCURACY } from '../modules/local/calc_imputation_accuracy'
include { PREPARE_RSQ_BROWSER_DATA } from '../modules/local/prepare_rsq_browser_data'

workflow MICROARRAY_EVAL {

  strand_data    =  channel.fromPath("${params.strand_data}/*strand", checkIfExists: true)
  sequence_data =  channel.fromPath("${params.sequence_data}/*vcf.gz", checkIfExists: true)


  strand_data.combine(sequence_data)
    .map { strand_data, sequence_data -> tuple(getChromosome(sequence_data), strand_data, sequence_data) }
    .set { strand_sequence_data }

  SIMULATE_ARRAY ( strand_sequence_data )

  IMPUTE_ARRAY ( SIMULATE_ARRAY.out.array_data.groupTuple() )

  // impute gets as an input both array files + sequence files. This method combines the correct results
  r2_input_data = IMPUTE_ARRAY.out.imputed_data
    .flatMap { chipname, dose_list, sequencefile_list, chromosome_list ->
            def result = []
            0.upto(chromosome_list.size() - 1) {
                result << [ chipname, dose_list.find {e -> /* find matching dose file for current data row */
                                e.endsWith("chr" + chromosome_list[it] + ".dose.vcf.gz")
                            }, sequencefile_list[it], chromosome_list[it] ]
            }
            return result /* result list is emitted per entry (data row) */
    }

   CALC_IMPUTATION_ACCURACY ( r2_input_data )

   PREPARE_RSQ_BROWSER_DATA (  CALC_IMPUTATION_ACCURACY.out.r2_data_out.groupTuple() )

}

// extract string or number after "chr"
def getChromosome(seq_file) {
    return ((seq_file.baseName =~ /[cC][hH][rR](\d{1,2}|[xX]|MT)/)[0][1])
}
