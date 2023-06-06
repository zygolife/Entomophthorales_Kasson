#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 2 -n 1 --mem 2gb --out logs/read_markers.gather.%a.log -a 1-14

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

	mkdir -p $OUT/$STRAIN
    ./scripts/diamondhits2seqfiles.py --left $IN/$STRAIN.R1.AFTOL_II.aln --right $IN/$STRAIN.R2.AFTOL_II.aln \
					    --leftdb $LEFTIN --rightdb $RIGHTIN \
					    --outdir $OUT/$STRAIN -s $OUT/$STRAIN.summary_stats.tsv \
              --evalue 0.001 --coverage 0.40
done
