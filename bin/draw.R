#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
ped_file	<- args[1]
variants	<- args[2]
output		<- args[3]

# Load data
pedigree <- pedtools::readPed(ped_file)

size <- pedtools::pedsize(pedigree)
file_name <- paste0(output, ".png")

# Extract marker names
markers <- unlist(strsplit(variants, ","))

png(file_name,
    width = size/1.5, height = size,
    units = 'in', res = 300)

# Plot the pedigree  
plot(
	pedigree,
	marker = markers,
	margins = c(0.6, 1, 4, 1)
)

dev.off()