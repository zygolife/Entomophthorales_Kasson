#!/bin/bash -l
#SBATCH --ntasks 2 --mem 24G --time 2:00:00 -p short -N 1 --out logs/phyling_init_search.log
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
#echo " I will remove prefix.tab to make sure it is regenerated"
#rm -f prefix.tab
../PHYling_unified/PHYling init
../PHYling_unified/PHYling search -q slurm
