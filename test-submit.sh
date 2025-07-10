#!/bin/bash

#SBATCH -o tests/tests.out
#SBATCH -e tests/tests.err
#SBATCH -J tests
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Load conda environment
module load Java/17
source $NXF_CONDA

# Setup tests
# curl -fsSL https://get.nf-test.com | bash
# ./nf-test init
# ./nf-test generate pipeline main.nf

# Download input data
mkdir -p tests
# URL="https://figshare.com/ndownloader/files"
# wget -c $URL/56135969 -O input.zip
# unzip -o input.zip -d tests/

# # Run tests
# # ./nf-test test tests/main.nf.test

# # Run nextflow (example)
cd tests/
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,test \
    -resume
