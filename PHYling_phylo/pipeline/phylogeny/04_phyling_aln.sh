#!/bin/bash -l
#SBATCH -c 128 -n 1 --mem 128G --time 2:00:00 -p short -N 1 --out logs/align_parallel.log

module load miniconda3
conda activate /bigdata/stajichlab/shared/condaenv/phyling
if [ ! -f config.txt ]; then
    echo "Need config.txt for PHYling"
    exit
fi

source config.txt

if [ ! -z $PREFIX ]; then
    rm -rf aln/$PREFIX
fi
# probably should check to see if allseq is newer than newest file in the folder?
../PHYling_unified/PHYling aln -c -q parallel
