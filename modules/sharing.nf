process SHARING {
    tag "${famid}:${pheno}:${category}:${type}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/sharing", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
		path(annotations), path(rlist), path(frq_strat),
            path(frqx), path(snplist), path(log),
            val(type)
            
    output:
    tuple val(famid), val(pheno), val(category), val(type),
          path("${famid}.${pheno}.${category}.${type}.tsv")

    script:
    """
    #!/bin/bash
    sharing.R ${famid} ${pheno} ${category} ${ped} ${annotations} ${rlist} ${frq_strat} ${type}
    """
}
