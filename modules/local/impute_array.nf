process IMPUTE_ARRAY {

    publishDir "${params.outdir}/${array_name}", mode: 'copy', pattern: '*.gz'

    input:
    tuple val(array_name), path(simulated_arrays), val(chr)

    output:
    tuple val(array_name), path("*.dose.vcf.gz"), val(chr), emit: imputed_data
    path("*.info.gz")

    shell:
    '''
    pwd=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

    imputationbot add-instance !{params.imputation_host} !{params.imputation_token}

    imputationbot impute \
      --files !{simulated_arrays} \
      --refpanel !{params.imputation_panel} \
      --build !{params.sequence_build} \
      --autoDownload \
      --password ${pwd} \
      --population !{params.imputation_population} \
      --phasing !{params.imputation_phasing}

    mv job-*/local/*.dose.vcf.gz .
    mv job-*/local/*.info.gz .

    rm job-*/local/*.zip
    '''
}
