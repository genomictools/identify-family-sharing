process DRAW {
    tag "${famid}:${pheno}:${category}:${gene}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/plots", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category),
          path(ped), path(affected), path(carrier),
          val(gene), val(variant)

    output:
    tuple val(famid), val(pheno), val(category), val(gene),
          path("${famid}.${pheno}.${category}.${gene}.png")

    script:
    """
    #!/bin/bash
    draw.R ${famid} ${pheno} ${category} ${ped} ${affected} ${carrier} ${gene} ${variant.join(',')}
    """
}
