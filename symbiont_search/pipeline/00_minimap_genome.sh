#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 16 --mem 8gb --out search_Sulcia.log

module load minimap2
module load parallel

DB=db/GCF_024817835.1_ASM2481783v1_genomic.fna
mkdir -p results/genome_align
parallel -j 4 minimap2 -t 4 -x asm20 --cs=long $DB {} \> results/genome_align/{/.}.paf ::: $(ls search/*.fa)

