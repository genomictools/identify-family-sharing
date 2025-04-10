#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
famid    	<- args[1]
pheno    	<- args[2]
category    <- args[3]
ped_file	<- args[4]
affected    <- args[5]
carrier	    <- args[6]
type 	    <- args[7]
gene 	    <- args[8]
variant 	<- args[9]

# Load data
pedigree <- pedtools::readPed(ped_file)
affected <- readr::read_lines(affected)
carrier  <- readr::read_lines(carrier)

size <- pedtools::pedsize(pedigree)
file_name <- paste(famid, pheno, category, type, gene, "png", sep = '.')

# Extract marker names
markers <- unlist(strsplit(variant, split = ','))
title <- paste(c(famid, gene, markers), collapse = '\n')

# Plot the pedigree  
png(file_name,
    width = size/1.5, height = size,
    units = 'in', res = 300)

plot(
	pedigree,
    aff = affected,
    carrier = carrier,
	marker = markers,
    margins = c(0.6, 1, length(markers) + 4, 1),
    title = title
)

dev.off()
