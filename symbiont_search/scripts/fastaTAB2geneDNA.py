#!/usr/bin/env python3

import argparse
import os
import re
import csv
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

parser = argparse.ArgumentParser(
    description='gene seq from BLASTN/FASTA')

parser.add_argument('-i', '--input', default='results',
                    help='FASTA results folder')

parser.add_argument('-e', '--evalue', default=1e-10,
                    help='evalue-cutoff')

parser.add_argument('-p', '--pid', default=50,
                    help='percent ID cutoff')

parser.add_argument('-o', '--output', default='genes',
                    help='output folder')

parser.add_argument('-oe', '--outputextension', default='gene.fasta',
                    help='output extension')

parser.add_argument('--tabext', default='tab',
                    help='FASTA file ext')

parser.add_argument('--genomedir', default='genomes',
                    help='genomes directory')

parser.add_argument('--genomeextension', default='fa',
                    help='genome file extension')

args = parser.parse_args()
if not os.path.exists('idx'):
    os.mkdir('idx')
# make directories for storing alignments and protein files
for d in [args.output]:
    if not os.path.exists(d):
        os.mkdir(d)

for tfile in (os.listdir(args.input)):
    if not tfile.endswith("."+args.tabext):
        continue
    spname = re.sub(r'(\.FASTA)?\.'+args.tabext, '', tfile)
    shortspname = re.sub(r'^CCGP[^_]+_JNA_AS_(\w+)_S\d+_L\d+_R', r'\1', spname)
    seq_file = os.path.join(args.genomedir, f"{spname}.{args.genomeextension}")
    record_dict = SeqIO.index_db(f'idx/{shortspname}.idx', seq_file, "fasta")
    # record_dict = SeqIO.to_dict(SeqIO.parse(seq_file, "fasta"))

    handle = open(os.path.join(args.input, tfile))
    # Read the tab file
    csvin = csv.reader(handle, delimiter="\t")
    genes = []
    n = 1
    for row in csvin:
        if float(row[2]) < args.pid or float(row[10]) > args.evalue:
            continue
        rec = record_dict[row[1]]
        qstart = int(row[6])
        qend = int(row[7])
        start = int(row[8])
        end = int(row[9])
        reverse = 0
        if end < start:
            reverse = 1
            (end, start) = (start, end)
        if qend < qstart:
            reverse = 1 - reverse
        dna_seq = rec[start:end]
        dirstr = 'fwd'
        if reverse:
            dirstr = 'rev'
            dna_seq = dna_seq.reverse_complement()
        # only take first best hit
        desc = f"direction:{dirstr} pid:{row[2]} evalue:{row[10]} {row[1]}_{row[8]}_{row[9]}"
        genes.append(SeqRecord(seq=dna_seq.seq, 
                     id=f'{shortspname}_n{n}_{row[1]}',
                     description=desc))
        n += 1
    SeqIO.write(genes, f'{args.output}/{shortspname}.{args.outputextension}',
                'fasta')

