process SUBSET {
    tag "${pheno}:${famid}"

    label 'simple'

    container params.bcftools

    publishDir("${params.output_dir}/subsets", mode: 'copy')

    input:
    tuple val(famid), val(pheno), path(ped),
          path(file), path(index)

    output:
    tuple val(famid), val(pheno), path(ped),
          path("${famid}.${pheno}.vcf.gz"),
          path("${famid}.${pheno}.vcf.gz.tbi"),
		  env(n_vars)

    script:
    """
    #!/bin/bash
    # Subset pheno for family members
    bcftools view --force-samples -g het -S <(tail -n +2 ${ped} | cut -f 2) ${file} | \
    bcftools view -i 'FILTER="PASS"' | \
    bcftools norm -m -any | \
    bcftools view -g het --threads ${task.cpus} -Oz -o ${famid}.${pheno}.vcf.gz

    # Index the VCF file
    tabix ${famid}.${pheno}.vcf.gz

	# Count the number of variants
    n_vars=\$(bcftools index -n ${famid}.${pheno}.vcf.gz)
    """
}
