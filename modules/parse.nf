process PARSE {
    tag "${pheno}:${famid}:${category}"

    label 'simple'

    container params.bioconductor

    publishDir("${params.output_dir}/models", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
          path(file), path(index), path(variants),
          val(n_vars)

    output:
    tuple val(famid), val(pheno), val(category), 
          path("${famid}.${pheno}.${category}.clean.ped"),
          path(file), path(index), path(variants),
          val(n_vars)
        
    script:
    """
    #!/bin/bash
    zcat ${file} | grep '#CHROM' | cut -f 10- | tr '\\t' '\\n' > sequenced.txt
    parse.R sequenced.txt ${ped} ${famid}.${pheno}.${category}.clean.ped
    """
}
