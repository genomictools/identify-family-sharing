#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)

seq_file       <- args[1]
ped_file       <- args[2]
out_file       <- args[3]

# setwd('/data/rds/DGE/DUDGE/MOPOPGEN/mahmed03/pipelines/identify-family-sharing/test/work/e8/842da6f46ba8b3fb5e9706919bf104')
# vcf_file <- 'FAM_02.pheno.High.vcf.gz'
# ped_file <- 'FAM_02.ped'
# seq_file <- 'sequenced.txt'

sequenced <- readr::read_lines(seq_file)

ped <- readr::read_tsv(ped_file)
ped <- dplyr::select(ped, -carr)
ped <- dplyr::mutate_all(ped, ~ifelse(is.na(.x), 0, .x))
ped <- dplyr::mutate_at(ped, dplyr::vars(c(id, mid, fid)), ~ifelse(.x %in% sequenced, .x, 0))
ped <- dplyr::filter(ped, id != '0')

readr::write_tsv(ped, out_file)
