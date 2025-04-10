process FILL {
    tag "${famid}:${pheno}"

    label 'simple'

    container params.bcftools

    publishDir("${params.output_dir}/filled", mode: 'symlink')

    input:
    tuple val(famid), val(pheno), path(ped),
          path(file), path(index), val(n_vars)

    output:
    tuple val(famid), val(pheno), path(ped),
          path("${famid}.${pheno}.filled.vcf.gz"),
          path("${famid}.${pheno}.filled.vcf.gz.tbi"),
          env(n_vars)

    script:
    """
    #!/bin/bash
    # Subset pheno
    bcftools view ${file} | \
    bcftools +setGT -- -t . -n 0 | \
    bcftools +fill-tags -- -t all | \
    bcftools +setGT -- -t q -n 0 -i 'FMT/GQ < ${params.GQ} | FMT/DP < ${params.DP} | VAF < ${params.VAF}' | \
    bcftools +fill-tags -- -t all | \
    bcftools view -g het --threads ${task.cpus} -Oz -o ${famid}.${pheno}.filled.vcf.gz
    
    # Index the VCF file
    tabix ${famid}.${pheno}.filled.vcf.gz

    # Count the number of variants
    n_vars=\$(bcftools index -n ${famid}.${pheno}.filled.vcf.gz)
    """
}
