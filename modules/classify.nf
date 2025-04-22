process CLASSIFY {
    tag "${pheno}:${category}:${type}"

    label 'simple'

    container = params.rvs

    publishDir("${params.output_dir}/classified", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(sharing), val(type)
  
    output:
    tuple val(pheno), val(category), val(type), path("${pheno}.${category}.${type}.tsv")

    script:
    """
    #!/bin/bash
    classify.R ${pheno} ${category} ${sharing.join(',')} ${type}
    """
}
