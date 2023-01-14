#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 8 --mem 8gb

module load fasttree
module load clipkit
module load mafft
REF=ref
mkdir -p aln
for d in $(ls genes)
do
    cat $REF/$d.fas genes/$d/* > aln/$d.fas
    mafft aln/$d.fas > aln/$d.fasaln
    clipkit aln/$d.fasaln
    FastTreeMP -nt -gtr -gamma < aln/$d.fasaln > aln/$d.FT.tre
done