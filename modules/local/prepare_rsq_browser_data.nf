process PREPARE_RSQ_BROWSER_DATA {

publishDir "${params.pubDir}/${array_name}", mode: 'copy'

    input:
    tuple val(array_name), path(array)

    output:
    tuple path("*.tab.gz"), path("*tab.gz.tbi")

    shell:
    '''
    resultfile=!{array_name}.tab

    echo -e "CHR\tPOS\tREF\tALT\tAF\tR2_!{array_name}" > $resultfile

   for FILE in *.RSquare;
        do
            tail -n +2 $FILE | sed 's/:/\t/g' | awk '{ print $1, $2, $3, $4, $8, $7 }' OFS='\t' >> $resultfile
        done

   bgzip $resultfile
   tabix -s1 -b2 -e2 -S1 $resultfile.gz

   '''
}
