process DRAW {
    tag "${famid}:${pheno}:${category}:${type}:${gene}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/plots", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category),
          path(ped), path(affected), path(carrier),
          val(type), val(gene), val(variant)

    output:
    tuple val(famid), val(pheno), val(category), val(type), val(gene),
          path("${famid}.${pheno}.${category}.${type}.${gene}.png")

    script:
    """
    #!/bin/bash
    draw.R ${famid} ${pheno} ${category} ${ped} ${affected} ${carrier} ${type} ${gene} ${variant.join(',')}
    """
}
