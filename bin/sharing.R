#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)

ped_file  <- args[1]
bim       <- args[2]
bed       <- args[3]
fam       <- args[4]
type      <- args[5]
out_file  <- args[6]

# setwd('/data/rds/DGE/DUDGE/MOPOPGEN/mahmed03/childhood_cancer/wtnb_families/')
# 
# bim       <- 'results/plinked/FACT5726.wtnb.Stop.bim'
# bed       <- 'results/plinked/FACT5726.wtnb.Stop.bed'
# fam       <- 'results/plinked/FACT5726.wtnb.Stop.fam'
# ped_file  <- 'results/plinked/FACT5726.wtnb.Stop.ped'
# type      <- 'affected'

# Load plink files
plnk <- snpStats::read.plink(bed, bim, fam)
rownames(plnk$genotypes) <- plnk$fam$member

# Load pedigree
d <- readr::read_tsv(
  ped_file,
  col_names = c('id', 'dadid', 'momid', 'sex', 'affected', 'famid')
)

d$affected <- ifelse(d$affected == 0, NA, d$affected - 1)
d$sex <- ifelse(d$sex == 0, 1, d$sex)

pdg <- with(d, kinship2::pedigree(id, dadid, momid, sex, affected, famid = famid))

if ( type == 'affected' ) {
  # carriers are the affected
  carrs <- pdg$id[pdg$affected == 1]
} else if ( type == 'complete') {
} else if ( type == 'partial') {
} else {
  stop("Sharing type is not recognized.")
}

# Calculate probability of sharing among carriers
prob <- RVS::RVsharing(pdg[1], carriers = carrs)
names(prob) <- unique(d$famid)

# Calculate p-values of sharing among carriers
sharing <- RVS::multipleVariantPValue(
  plnk$genotypes,
  famInfo = plnk$fam,
  sharingProbs = prob
)

# Format the output
res <- tibble::tibble(
  famid = names(prob),
  variants = names(sharing$pvalues),
  pvalues = sharing$pvalues,
  potential_pvalues = sharing$potential_pvalues
)

# Save the results
readr::write_tsv(res, out_file)
