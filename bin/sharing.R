#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)

famid    <- args[1]
pheno    <- args[2]
category <- args[3]
ped_file <- args[4]
bim      <- args[5]
bed      <- args[6]
fam      <- args[7]
variants <- args[8]
type     <- args[9]

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
sharing_df <- tibble::tibble(
  famid = famid,
  variant = names(sharing$pvalues),
  pvalues = sharing$pvalues,
  potential_pvalues = sharing$potential_pvalues
)

# Annotations
anno <- readr::read_tsv(variants)
anno <- dplyr::select(anno, variant = SNP, gene = SYMBOL)

# File ids
ids <- tibble::tibble(
  famid = famid,
  pheno = pheno,
  category = category,
  type = type)

# Save the results
res <- dplyr::left_join(ids, sharing_df)
res <- dplyr::left_join(res, anno)
out_file  <- paste(famid, pheno, category, type, 'tsv', sep = '.')
readr::write_tsv(res, out_file)
