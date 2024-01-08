process LIFT_OVER {

//publishDir "${params.outdir}/aggRSquare", mode: 'copy', pattern: '*aggRSquare'

    input:
    tuple val(chr), val(array_name), path(dosage_data), path(sequence_data)

    output:
    tuple val(chr), val(array_name), path(dosage_data), path("${sequence_data.baseName}.liftover.vcf.gz"), emit: sequence_data_lifted

    script:
    def chain_file = (params.sequence_build == 'hg19' ? "/opt/imputationserver/chains/hg19ToHg38.over.chain.gz" : '/opt/imputationserver/chains/hg38ToHg19.over.chain.gz')

    """
    java -jar /opt/imputationserver/imputationserver.jar vcf-liftover --input $sequence_data --output ${sequence_data.baseName}.liftover.vcf.gz --chain $chain_file
    """
}