#!/bin/bash

#SBATCH -o tests/tests.out
#SBATCH -e tests/tests.err
#SBATCH -J tests
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p tests/

TESTDATA="git@github.com:genomictools/test-datasets.git"
BRANCH="identify-family-sharing"
SRC="tests/input"

git -C $SRC pull || \
git clone -b $BRANCH $TESTDATA $SRC

# Run nextflow
module load Nextflow

cd tests/

# nextflow run genomictools/identify-family-sharing -r main \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,test \
    -resume
