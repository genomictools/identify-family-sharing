#!/bin/bash

#SBATCH -o test/test.out
#SBATCH -e test/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p test/ test/input
cd test/

# Download test data
URL="https://figshare.com/ndownloader/files"

wget -c $URL/50690370 -O input/pheno.variants.vcf.gz
wget -c $URL/50690373 -O input/pheno.variants.vcf.gz.tbi
wget -c $URL/53887718 -O input/blacklist.txt
wget -c $URL/53574317 -O input/FAM_01.ped
wget -c $URL/53574314 -O input/FAM_02.ped
wget -c $URL/53574311 -O input/FAM_03.ped

# Create cohorts_info.csv
echo "pheno,file,index,family,pedigree" > input/cohorts_info.csv
echo "pheno,input/pheno.variants.vcf.gz,input/pheno.variants.vcf.gz.tbi,FAM_01,input/FAM_01.ped," >> input/cohorts_info.csv
echo "pheno,input/pheno.variants.vcf.gz,input/pheno.variants.vcf.gz.tbi,FAM_02,input/FAM_02.ped," >> input/cohorts_info.csv
echo "pheno,input/pheno.variants.vcf.gz,input/pheno.variants.vcf.gz.tbi,FAM_03,input/FAM_03.ped," >> input/cohorts_info.csv

# Run nextflow
module load Nextflow

# nextflow run houlstonlab/identify-family-sharing -r main \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,test \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint

mv .nextflow.log nextflow.log