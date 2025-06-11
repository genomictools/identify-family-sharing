process MODEL {
    tag "${pheno}:${famid}:${category}"

    label 'simple'

    container params.genmod

    publishDir("${params.output_dir}/models", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
          path(file), path(index), path(variants),
          val(n_vars)

    output:
    tuple val(famid), val(pheno), val(category), 
        //   path(ped),
          path("${famid}.${pheno}.${category}.model.vcf.gz"),
        //   path("${famid}.${pheno}.${category}.model.vcf.gz.tbi"),
		//   path(variants),
          val(n_vars)
        
    script:
    """
    #!/bin/bash
    genmod models \
        ${file} \
        --family_file ${ped} \
        --family_type ped \
        --vep \
        --processes ${task.cpus} \
        --outfile ${famid}.${pheno}.${category}.model.vcf.gz \
    """
}
