#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 32 -n 1 --mem 24gb --out logs/read_markers.gather.%a.log

module load samtools
module load workspace/scratch
module load biopython

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

SAMPLEFILE=samples.csv
FASTQ=input
IN=AFTOL_search/search
OUT=AFTOL_search/marker_find
mkdir -p $OUT
IFS=, # set the delimiter to be ,
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read BASE ILLUMINASAMPLE SPECIES STRAIN PROJECT DESCRIPTION ASMFOCUS
do
    LEFTIN=$FASTQ/${BASE}_${ILLUMINASAMPLE}_R1_001.fastq.gz
    RIGHTIN=$FASTQ/${BASE}_${ILLUMINASAMPLE}_R2_001.fastq.gz
	if [ ! -f $SCRATCH/${BASE}_R1.fq ]; then
		pigz -dc $LEFTIN > $SCRATCH/${BASE}_R1.fq
		samtools fqidx $SCRATCH/${BASE}_R1.fq
	fi
	if [ ! -f $SCRATCH/${BASE}_R2.fq ]; then
		pigz -dc $RIGHTIN > $SCRATCH/${BASE}_R2.fq
		samtools fqidx $SCRATCH/${BASE}_R2.fq
	fi

	mkdir -p $OUT/$STRAIN
    ./scripts/diamondhits2seqfiles.py --left $IN/$STRAIN.R1.AFTOL_II.aln --right $IN/$STRAIN.R2.AFTOL_II.aln \
					    --leftdb $SCRATCH/${BASE}_R1.fq --rightdb $SCRATCH/${BASE}_R1.fq \
					    --outdir $OUT/$STRAIN --evalue 0.001 --coverage 0.40
done
