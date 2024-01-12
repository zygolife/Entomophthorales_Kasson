#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 2 --mem 1gb

module load samtools
OUTFOLDER=target_loci
RESULTDIR=results
mkdir -p $OUTFOLDER
for Q in $(ls lib/*.fa)
do
    qname=$(basename $Q .fa)
    for genome in $(ls target/*.fa)
    do
	spname=$(basename $genome .fa)
	OUT=$OUTFOLDER/$spname.$qname.hits.fa
	resultfile=$RESULTDIR/$qname.$spname.FASTA.tab
	grep -v ^# $resultfile | while read QUERY HIT PID GAPOPEN GAPLEN QSTART QEND TSTART TEND EVALUE SCORE
	do
	    samtools faidx $genome $HIT
	done > $OUT
    done
done
