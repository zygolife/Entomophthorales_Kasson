#!/bin/bash -l
#SBATCH -p short -C xeon -N 1 -c 64 --mem 255gb --out logs/mmseqs_classify.%a.log -a 1
hostname
module load mmseqs2
module load workspace/scratch

DB=/srv/projects/db/ncbi/mmseqs/swissprot
DB2=/srv/projects/db/ncbi/mmseqs/uniref50

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi

SAMPLES=samples.csv
LIB=samples.csv
IFS=,
tail -n +2 $LIB | sed -n ${N}p | while read SAMPLE ILLSAMP SPECIES STRAIN PROJECT DESCRIPTION ASSEMBLYFOCUS
do
    BINS=results/$STRAIN/bins/${SAMPLE}_${ILLSAMP}.bin
    OUTSEARCH=results/$STRAIN/bins_mmseq_taxonomy
    mkdir -p $OUTSEARCH
    for ASM in $(ls ${BINS}.*.fa)
    do	
	NAME=$(basename $ASM .fa)
	mmseqs easy-taxonomy $ASM $DB2 $OUTSEARCH/$NAME $SCRATCH --threads $CPU --lca-ranks kingdom,phylum,family  --tax-lineage 1
    done
done
