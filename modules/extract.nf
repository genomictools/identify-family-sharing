process EXTRACT {
    tag "${famid}:${pheno}:${category}:${variable}"

    label 'simple'

    container params.plink

    publishDir("${params.output_dir}/variants", mode: 'copy')

    input:
    tuple val(famid), val(pheno), val(category),
          path(ped), path(bim), path(bed), path(fam), path(nosex), path(log),
		  path(annotations), 
		  val(variable)

    output:
    tuple val(famid), val(pheno), val(category), val(variable),
	      path("${famid}.${pheno}.${category}.extracted.${variable}"),
	      path("${famid}.${pheno}.${category}.extracted.log")

    script:
    if ( variable == 'list' ) {
		"""
		#!/bin/bash
		plink --bfile ${bim.baseName} --recode list --out ${famid}.${pheno}.${category}.extracted
		"""
    } else if ( variable == 'rlist' ) {
		"""
		#!/bin/bash
		plink --bfile ${bim.baseName} --recode rlist --out ${famid}.${pheno}.${category}.extracted
		"""
    } else if ( variable == 'snplist' ) {
		"""
		#!/bin/bash
		plink --bfile ${bim.baseName} --write-snplist --out ${famid}.${pheno}.${category}.extracted
		"""
    } else if ( variable == 'frqx' ) {
		"""
		#!/bin/bash
		plink --bfile ${bim.baseName} --freqx --nonfounders --out ${famid}.${pheno}.${category}.extracted
		"""
    } else {
		println "Variable ${variable} not recognized"
	}
}
