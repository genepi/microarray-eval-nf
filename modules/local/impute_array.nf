process IMPUTE_ARRAY {

//publishDir "${params.outdir}/${array_name}", mode: 'copy'

    input:
    tuple val(array_name), path(simulated_arrays), val(chr), path(seq_file)

    output:
    tuple val(array_name), path("job-*/local/*.dose.vcf.gz"), path(seq_file), val(chr), emit: imputed_data
    val(chr), emit: test

    shell:
    '''
    pwd=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

    imputationbot add-instance !{params.imputation_host} !{params.imputation_token}
    imputationbot impute --files !{simulated_arrays} --refpanel !{params.imputation_panel} --build !{params.imputation_build} --autoDownload --password ${pwd} --population !{params.imputation_population}
    '''
}
