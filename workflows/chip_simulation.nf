requiredParams = [
    'project', 'sequence_data',
    'strand_data'
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


include { FILTER_SEQUENCE_DATA } from '../modules/local/filter_sequence_data'  addParams(outdir: "$outdir")
include { SIMULATE_ARRAY } from '../modules/local/simulate_array'  addParams(outdir: "$outdir")

workflow ARRAY_SIMULATION {

  strand_data   = channel.fromPath(params.strand_data, checkIfExists: true)
  sequence_data = channel.fromPath(params.sequence_data, checkIfExists: true)

  def sample_file = []

  if (params.sample_file != '') {
      sample_file = file(params.sample_file, checkIfExists: true)
  }

  FILTER_SEQUENCE_DATA (sequence_data, sample_file)
  sequence_data_filtered = FILTER_SEQUENCE_DATA.out.sequence_data_filtered

  // combine sequence data with chromosome
  sequence_data_filtered
    .map { sequence_data_filtered -> tuple(getChromosome(sequence_data_filtered), sequence_data_filtered) }
    .set { sequence_data_filtered_chromosome }

  // combine sequence or dosages data with array data
  if (params.dosage_data == null){
  strand_data.combine(sequence_data_filtered)
    .map { strand_data, sequence_data_filtered -> tuple(getChromosome(sequence_data_filtered), strand_data, sequence_data_filtered) }
    .set { strand_sequence_data }
  } else {
    dosage_data = channel.fromPath("${params.dosage_data}", checkIfExists: true)
    strand_data.combine(dosage_data)
      .map { strand_data, dosage_data -> tuple(getChromosome(dosage_data), strand_data, dosage_data) }
      .set { strand_sequence_data }
  }

  SIMULATE_ARRAY ( strand_sequence_data, sample_file )

}

// extract string or number after "chr"
def getChromosome(seq_file) {
    return ((seq_file.baseName =~ /[cC][hH][rR](\d{1,2}|[xX]|MT)/)[0][1])
}

workflow {
    ARRAY_SIMULATION ()
}