#!/bin/bash -l
#SBATCH -p short -N 1 -c 128 --mem 96gb -n 1 --out logs/make_PEP_trees.%A.log
module load fasttree

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
make -f ../PHYling_unified/util/makefiles/Makefile.trees HMM=fungi_odb10 -j $CPU PEP
