process ATTACH {
    tag "${famid}:${pheno}:${category}:${type}"

    label 'simple'

    container params.rvs

    publishDir("${params.output_dir}/markers/", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
          path(bim), path(bed), path(fam), path(nosex), path(log),
          path(annotations),
          val(type), path(sharing)

    output:
    tuple val(famid), val(pheno), val(category), val(type),
          path("${famid}.${pheno}.${category}.${type}.marked.ped")

    script:
    """
    #!/bin/bash
    attach.R ${bim} ${bed} ${fam} ${ped} ${famid}.${pheno}.${category}.${type}.marked
    """
}
