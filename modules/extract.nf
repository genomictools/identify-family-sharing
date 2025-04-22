process EXTRACT {
    tag "${famid}:${pheno}:${category}"

    label 'simple'

    container params.plink

    publishDir("${params.output_dir}/variants", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category), path(ped),
		  path(bim), path(bed), path(fam), path(nosex), path(log),
		  path(annotations)

    output:
    tuple val(famid), val(pheno), val(category), path(ped),
		  path(annotations), 
	      path("${famid}.${pheno}.${category}.extracted.rlist"),
	      path("${famid}.${pheno}.${category}.extracted.frq.strat"),
	      path("${famid}.${pheno}.${category}.extracted.frqx"),
	      path("${famid}.${pheno}.${category}.extracted.snplist"),
	      path("${famid}.${pheno}.cases.txt"),
	      path("${famid}.${pheno}.${category}.extracted.log")

    script:
	"""
	#!/bin/bash
	tail -n +2 ${ped} | awk '{print \$1, \$2, \$7}' > clusters.txt
	cat ${fam} | awk '{print \$2}' > ${famid}.${pheno}.cases.txt
	plink --bfile ${bim.baseName} --recode rlist  --out ${famid}.${pheno}.${category}.extracted
	plink --bfile ${bim.baseName} --write-snplist --out ${famid}.${pheno}.${category}.extracted
	plink --bfile ${bim.baseName} --freqx         --out ${famid}.${pheno}.${category}.extracted  --nonfounders 
	plink --bfile ${bim.baseName} --freq          --out ${famid}.${pheno}.${category}.extracted  --nonfounders --within clusters.txt 
	"""
}
