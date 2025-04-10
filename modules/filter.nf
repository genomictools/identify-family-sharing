process FILTER {
    tag "${pheno}:${famid}:${category}"

    label 'simple'

    container params.bcftools

    publishDir("${params.output_dir}/filtered", mode: 'copy')

    input:
    tuple val(famid), val(pheno), path(ped),
          path(file), path(index),
          val(n_vars),
          val(category)

    output:
    tuple val(famid), val(pheno), val(category), path(ped),
          path("${famid}.${pheno}.${category}.vcf.gz"),
          path("${famid}.${pheno}.${category}.vcf.gz.tbi"),
		  path("${famid}.${pheno}.${category}.annotation.tsv"),
          env(n_vars)
        
    script:
    """
    #!/bin/bash
    # Filter variants
    bcftools view ${file} | \
    bcftools +split-vep -s worst -c CLIN_SIG -e "CLIN_SIG ~ 'conflicting' || CLIN_SIG ~ 'benign'" | \
    if   [ ${category} == 'Pathogenic' ]; then bcftools +split-vep -s worst -c CLIN_SIG -i "CLIN_SIG ~ 'pathogenic' || CLIN_SIG ~ 'likely_pathogenic'";
    elif [ ${category} == 'Rare' ];       then bcftools +split-vep -s worst -c ${params.AF_COL}:Float,MAX_AF:Float -e "${params.AF_COL} > ${params.AF} || MAX_AF > ${params.AF}";
    elif [ ${category} == 'High' ];       then bcftools +split-vep -s worst -c IMPACT,CADD_PHRED:Float -i "IMPACT='HIGH' && CADD_PHRED > ${params.CADD}";
    elif [ ${category} == 'Damaging' ];   then bcftools +split-vep -s worst -c IMPACT,CADD_PHRED:Float -i "(IMPACT='HIGH' || IMPACT='MODERATE') && CADD_PHRED > ${params.CADD}";
    elif [ ${category} == 'PTV' ];        then bcftools +split-vep -s worst -c Consequence -i "Consequence~'stop_gained' || Consequence~'frameshift_variant' || Consequence~'splice_acceptor_variant'";
    elif [ ${category} == 'Stop' ];       then bcftools +split-vep -s worst -c Consequence -i "Consequence~'stop_gained'";
    elif [ ${category} == 'Splicing' ];   then bcftools +split-vep -s worst -c SpliceAI_pred_DS_AG:Float,SpliceAI_pred_DS_AL:Float,SpliceAI_pred_DS_DG:Float,SpliceAI_pred_DS_DL:Float -i "SpliceAI_pred_DS_AG > ${params.DS} || SpliceAI_pred_DS_AL > ${params.DS} || SpliceAI_pred_DS_DG > ${params.DS} || SpliceAI_pred_DS_DL > ${params.DS}";
    else exit "Category: ${category} is not recognized"; fi | \
    bcftools annotate --set-id '%CHROM:%POS:%REF:%ALT' | \
    bcftools view --threads ${task.cpus} -Oz -o ${famid}.${pheno}.${category}.vcf.gz

    # Index the VCF
    tabix ${famid}.${pheno}.${category}.vcf.gz
    
	# Extract variant annotations
	echo -e "SNP\t\$(bcftools +split-vep -l ${file} | cut -f 2 | tr '\n' '\t')" > "${famid}.${pheno}.${category}.annotation.tsv"
    bcftools +split-vep \
	    -s worst \
		-f '%CHROM:%POS:%REF:%ALT\t%CSQ\n' \
		-d -A tab \
		${famid}.${pheno}.${category}.vcf.gz \
		>> "${famid}.${pheno}.${category}.annotation.tsv"
    
	# Count the number of variants
    n_vars=\$(bcftools index -n ${famid}.${pheno}.${category}.vcf.gz)
    """
}
