#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
famid    	<- args[1]
pheno    	<- args[2]
category  <- args[3]
ped_file	<- args[4]
type	    <- args[5]
gene	    <- args[6]
variants	<- args[7]

# Load data
pedigree <- pedtools::readPed(ped_file)

size <- pedtools::pedsize(pedigree)
file_name <- paste0(famid, pheno, category, type, gene, ".png")

# Extract marker names
markers <- unlist(strsplit(variants, ","))
title <- paste(c(famid, gene, markers), collapse = '\n')

png(file_name,
    width = size/1.5, height = size,
    units = 'in', res = 300)

# Plot the pedigree  
plot(
	pedigree,
	marker = markers,
    margins = c(0.6, 1, length(markers) + 4, 1),
    title = title
)

dev.off()
