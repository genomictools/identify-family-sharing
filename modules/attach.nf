process ATTACH {
    tag "${famid}:${pheno}:${category}"

    label 'simple'

    container params.rvs

    publishDir("${params.output_dir}/markers/", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped), 
          path(bim), path(bed), path(fam), path(nosex), path(log),
          path(variants)

    output:
    tuple val(famid), val(pheno), val(category),
          path("${famid}.${pheno}.${category}.marked.ped"),
          path("${famid}.${pheno}.affected.txt"),
          path("${famid}.${pheno}.carrier.txt")

    script:
    """
    #!/bin/bash
    attach.R ${bim} ${bed} ${fam} ${ped} ${famid}.${pheno}.${category}.marked
    tail -n +2 ${ped} | awk '{ if (\$6 > 1) print \$2}' > ${famid}.${pheno}.affected.txt
    tail -n +2 ${ped} | awk '{ if (\$7 > 0) print \$2}' > ${famid}.${pheno}.carrier.txt
    """
}
