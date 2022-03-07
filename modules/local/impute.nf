process IMPUTE {

publishDir "${params.outdir}/${array_name}", mode: 'copy'

    input:
    tuple val(array_name), path(simulated_arrays)

    output:
    tuple val(array_name), path("*.dose.vcf.gz")

    shell:
    '''
    pwd=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
    imputationbot add-instance !{params.imputation_host} !{params.imputation_token}
    imputationbot impute --files !{simulated_arrays} --refpanel !{params.imputation_panel} --build !{params.imputation_build} --autoDownload --password ${pwd} --population !{params.imputation_population}

    cp job-*/local/*.dose.vcf.gz .
    '''
}
