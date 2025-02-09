process DRAW {
    tag "${famid}:${pheno}:${category}:${type}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/plots", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), val(type), path(ped)

    output:
    tuple val(famid), val(pheno), val(category), val(type),
          path("${famid}.${pheno}.${category}.${type}.png"), optional: true

    script:
    """
    #!/bin/bash
    draw.R ${ped} ${famid}.${pheno}.${category}.${type}
    """
}
