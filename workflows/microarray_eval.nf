

requiredParams = [
    'project', 'sequence_data',
    'strand_data', 'imputation_host',
    'imputation_token', 'imputation_panel',
    'imputation_population', 'imputation_build',
    'sequence_build'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

if(params.outdir == null) {
  outdir = "output/${params.project}"
} else {
  outdir = params.outdir
}

if (!params.imputation_token) {
   exit 1, "[Pipeline error] Parameter 'token' is not set in the pipeline!\n"
}

include { FILTER_SEQUENCE_DATA } from '../modules/local/filter_sequence_data'  addParams(outdir: "$outdir")
include { SIMULATE_ARRAY } from '../modules/local/simulate_array'  addParams(outdir: "$outdir")
include { IMPUTE_ARRAY } from '../modules/local/impute_array' addParams(outdir: "$outdir")
include { LIFT_OVER } from '../modules/local/lift_over' addParams(outdir: "$outdir")
include { CALCULATE_IMPUTATION_ACCURACY } from '../modules/local/calculate_imputation_accuracy' addParams(outdir: "$outdir")
include { PREPARE_RSQ_BROWSER_DATA } from '../modules/local/prepare_rsq_browser_data' addParams(outdir: "$outdir")

workflow MICROARRAY_EVAL {

  strand_data   = channel.fromPath("${params.strand_data}", checkIfExists: true)
  sequence_data = channel.fromPath("${params.sequence_data}", checkIfExists: true)

  FILTER_SEQUENCE_DATA (sequence_data)
  sequence_data_filtered = FILTER_SEQUENCE_DATA.out.sequence_data_filtered


// combine sequence data with array data
  strand_data.combine(sequence_data_filtered)
    .map { strand_data, sequence_data_filtered -> tuple(getChromosome(sequence_data_filtered), strand_data, sequence_data_filtered) }
    .set { strand_sequence_data }

  SIMULATE_ARRAY ( strand_sequence_data )

  IMPUTE_ARRAY ( SIMULATE_ARRAY.out.array_data.groupTuple() )

  // impute gets as an input both array files + sequence files. This method combines the correct results
  r2_input_data = IMPUTE_ARRAY.out.imputed_data
    .flatMap { chipname, dose_list, sequencefile_list, chromosome_list ->
            def result = []
            if(chromosome_list.size() == 1) {
              result << [ chipname, dose_list, sequencefile_list, chromosome_list ]
              return result
            } else {
                for (i = 0; i < chromosome_list.size(); i++) {
                result << [ chipname, dose_list.find
                            {e -> /* find matching dose file for current data row */
                             e.endsWith("chr" + chromosome_list[i] + ".dose.vcf.gz")
                            }, sequencefile_list[i], chromosome_list[i] ]
                }
            return result
          }
    }

    // lift sequence data to allow comparision with aggRSquare
     if (params.imputation_build != params.sequence_build) {

       LIFT_OVER(r2_input_data)
       r2_input_data_lifted = LIFT_OVER.out.sequence_data_lifted

     } else {

       r2_input_data_lifted = r2_input_data

     }


  if (params.exec_rsq_steps) {

      CALCULATE_IMPUTATION_ACCURACY ( r2_input_data_lifted )

      PREPARE_RSQ_BROWSER_DATA (  CALCULATE_IMPUTATION_ACCURACY.out.r2_data_out.groupTuple() )
  }

}

// extract string or number after "chr"
def getChromosome(seq_file) {
    return ((seq_file.baseName =~ /[cC][hH][rR](\d{1,2}|[xX]|MT)/)[0][1])
}
