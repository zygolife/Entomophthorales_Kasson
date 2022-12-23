#!/usr/bin/bash -l

module load hmmer
DIR=AFTOL_search
mkdir -p $DIR
ln -s $(realpath PHYling_HMMs_fungi/HMM/AFTOL_70/markers_3.hmmb) $DIR/AFTOL_II.hmm
hmmemit -c $DIR/AFTOL_II.hmm > $DIR/AFTOL_II.cons.fa

module load diamond
diamond makedb --db  $DIR/AFTOL_II --in $DIR/AFTOL_II.cons.fa
