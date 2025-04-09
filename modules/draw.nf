process DRAW {
    tag "${famid}:${pheno}:${category}:${type}:${gene}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/plots", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category),
          path(ped),
          val(type), val(gene), val(variant),
          val(potential_pvalues), val(pvalues)

    output:
    tuple val(famid), val(pheno), val(category), val(type), val(gene),
          path("${famid}.${pheno}.${category}.${type}.${gene}.png"), optional: true

    script:
    """
    #!/bin/bash
    draw.R ${famid} ${pheno} ${category} ${ped} ${type} ${gene} ${variant.join(',')}
    """
}
