process SHARING {
    tag "${famid}:${pheno}:${category}:${type}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/sharing", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category),
          path(ped), path(bim), path(bed), path(fam), path(nosex), path(log),
          val(type)

    output:
    tuple val(famid), val(pheno), val(category), val(type),
          path("${famid}.${pheno}.${category}.${type}.tsv")

    script:
    """
    #!/bin/bash
    sharing.R ${ped} ${bim} ${bed} ${fam} ${type} ${famid}.${pheno}.${category}.${type}.tsv
    """
}
