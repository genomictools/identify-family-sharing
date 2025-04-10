#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)

famid    <- args[1]
pheno    <- args[2]
category <- args[3]
ped_file <- args[4]
annotations <- args[5]
rlist    <- args[6]
frq      <- args[7]
type     <- args[8]

# ped_file    <- 'wtnb_families/results/variants/FACT0471.ped'
# annotations <- 'wtnb_families/results/variants/FACT0471.wtnb.Rare.annotation.tsv'
# rlist       <- 'wtnb_families/results/variants/FACT0471.wtnb.Rare.extracted.rlist'
# frq         <- 'wtnb_families/results/variants/FACT0471.wtnb.Rare.extracted.frq.strat'

# annotations
anno <- readr::read_tsv(annotations)
anno <- dplyr::select(anno, variant = SNP, gene = SYMBOL, ensembl = Gene, IMPACT, Consequence, clinsig = CLIN_SIG)

# rlist
ids <- unlist(readr::read_tsv(ped_file, col_select = 2))

rlist <- readr::read_delim(rlist, delim = ' ', col_names = c('variant', 'genotype', 'alt', 'ref'))
rlist <- tidyr::unite(rlist, samples, dplyr::starts_with('X'), sep = ' ')
rlist <- dplyr::mutate(rlist, samples = purrr::map_chr(stringr::str_split(samples, ' '), ~{paste(intersect(ids, unlist(.x)), collapse = ',')}))
rlist <- dplyr::select(rlist, variant, genotype, samples)
rlist <- tidyr::pivot_wider(rlist, names_from = 'genotype', values_from = 'samples')

# pedigree
clusters <- tibble::tibble(
  V1 = as.integer(0:3),
  V2 = c('non', 'potential', 'affected', 'obligate')
)

# expected numbers in each cluster
carr <- readr::read_tsv(ped_file, col_select = 7)
carr <- dplyr::left_join(carr, clusters, by = c('carr' = 'V1'))
carr <- dplyr::group_by(carr, cluster = V2)
carr <- dplyr::reframe(carr, expected = dplyr::n())

# mac in each cluster
frq <- read.table(frq, skip = 1)
frq <- setNames(frq, c('chrom', 'variant', 'cluster', 'alt', 'ref', 'maf', 'mac', 'nchromobs'))
frq <- dplyr::left_join(frq, clusters, by = c('cluster' = 'V1'))
frq <- dplyr::select(frq, variant, mac, cluster = V2)
frq <- tibble::as_tibble(frq)

# merge
res <- dplyr::left_join(frq, carr)
res <- dplyr::left_join(res, rlist)
res <- dplyr::left_join(res, anno)
res <- tidyr::pivot_wider(res, values_from = c('mac', 'expected'), names_from = 'cluster')

# Write output
output <- paste(famid, pheno, category, type, 'tsv', sep = '.')
readr::write_tsv(res, output)
