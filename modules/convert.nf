process CONVERT {
    tag "${famid}:${pheno}:${category}"

    label 'simple'

    container = params.plink

    publishDir("${params.output_dir}/plinked", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
          path(file), path(index), path(variants), val(n_vars)

    output:
    tuple val(famid), val(pheno), val(category), path(ped),
          path("${famid}.${pheno}.${category}.bim"),
          path("${famid}.${pheno}.${category}.bed"),
          path("${famid}.${pheno}.${category}.fam"),
          path("${famid}.${pheno}.${category}.nosex"),
          path("${famid}.${pheno}.${category}.log"),
          path(variants)

    script:
    """
    #!/bin/bash
    tail -n +2 ${ped} | awk '{print \$1, \$2, \$3, \$4}' > parents.txt
    tail -n +2 ${ped} | awk '{print \$1, \$2, \$5}'      > sex.txt
    tail -n +2 ${ped} | awk '{print \$1, \$2, \$6}'      > aff.txt

    # Convert VCF to PLINK format
    plink \
        --vcf ${file} \
        --make-bed \
        --const-fid ${famid} \
        --update-parents parents.txt \
        --update-sex sex.txt \
        --pheno aff.txt \
        --out ${famid}.${pheno}.${category}
    """
}
