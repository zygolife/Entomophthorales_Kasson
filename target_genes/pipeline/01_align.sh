#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 64 --mem 8gb

module load fasta
module load parallel

for Q in $(ls lib/*.fa)
do
	qname=$(basename $Q .fa)
	parallel -j 32 ssearch36 -m 8c -T 2 -E 1e-3 $Q {} \> results/$qname.{/.}.FASTA.tab ::: $(ls target/*.fa)
done
