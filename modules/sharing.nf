process SHARING {
    tag "${famid}:${pheno}:${category}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/sharing", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
		path(annotations), path(rlist), path(frq_strat),
            path(frqx), path(snplist), path(cases), path(log),
            path(blacklist)
            
    output:
    tuple val(famid), val(pheno), val(category),
          path("${famid}.${pheno}.${category}.tsv")

    script:
    """
    #!/bin/bash
    sharing.R ${famid} ${pheno} ${category} ${ped} ${annotations} ${rlist} ${frq_strat} ${cases} ${blacklist}
    """
}
