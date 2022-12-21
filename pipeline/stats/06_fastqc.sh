#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 16 --mem 8gb --out logs/fastqc.%a.log -a 1-14

module load workspace/scratch
module load fastqc

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
QC=qc/fastqc
FASTQFOLDER=input
SAMPLEFILE=samples.csv
MAX=$(wc -l $SAMPLEFILE | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in samplefile=$SAMPLEFILE"
  exit
fi
mkdir -p $QC
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read BASE ILLUMINASAMPLE SPECIES STRAIN PROJECT DESCRIPTION ASMFOCUS
do
	fastqc -t $CPU -o $QC/$STRAIN -f fastq $FASTQFOLDER/${BASE}_${ILLUMINASAMPLE}_R[12]_001.fastq.gz)
done
