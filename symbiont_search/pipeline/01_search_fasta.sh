#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 16 --mem 24gb --out logs/search_markers.%A.log

module load biopython
module load fasta
module load parallel
GENOMEDIR=search
mkdir -p results genes
for Q in query_marker/*.fas
do
	B=$(basename $Q .fas)
	mkdir -p results/$B genes/$B
	# parallel -j 2 fasta36 -E 1e-10 -m 8c $Q {} \> results/$B/{/.}.FASTA.tab ::: $(ls $GENOMEDIR/*.fa)
	./scripts/fastaTAB2geneDNA.py --input results/$B --genomedir $GENOMEDIR --output genes/$B
done
