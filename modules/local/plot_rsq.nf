process PLOT_RSQ {

    publishDir "${params.pubDir}/rsq", mode: 'copy', pattern: '*html'

    input:
    path(agg_rsq)
    path(rsq_report)

    output:
    path("*.html")

    script:
    """
    csvtk concat -C '\$' -t -T $agg_rsq -o combined.txt

    Rscript -e "require( 'rmarkdown' ); render('${rsq_report}',
        params = list(
            input = 'combined.txt',
            name = '${params.project}',
            version = paste('${workflow.manifest.name}', '(v${workflow.manifest.version})'),
            date = '${params.project_date}'
        ),
        intermediates_dir='\$PWD',
        knit_root_dir='\$PWD',
        output_file='\$PWD/"${params.project}".html'
    )"
    """

}
