#!/usr/bin/env python3

import csv, re, sys, os, argparse
import xml.etree.ElementTree as ET
from Bio import Entrez

Entrez.email = 'jason@bioperl.org'
outsamples="coi.tsv"
query="txid231213[Organism:exp]"

parser = argparse.ArgumentParser("generate_NCBI_genome_download.py",add_help=True)
parser.add_argument("-v","--verbose", help="Print out Verbose processing",action='store_true')
parser.add_argument("--debug", help="Debug only printing one record",action='store_true')
parser.add_argument("-e","--email", help="Email address for Entrez query",required=False)
parser.add_argument("-q","--query", help="Entrez Genome Query",required=False)
parser.add_argument("-m","--max", type=int, help="Maximum number of records to retrieve",default=2)
parser.add_argument("-o","--out", type=argparse.FileType('w'), help="Output file name",default="genomes.tsv")

args = parser.parse_args()

if args.email:
    Entrez.email = args.email
if args.query:
    query = args.query

handle = Entrez.esearch(db="genome",term=query,retmax=args.max)
record = Entrez.read(handle)

for genomeID in record["IdList"]:
    print("Genome ID is ",genomeID)

    ghandle = Entrez.esummary(db="genome", id=genomeID)
    gasm = Entrez.read(ghandle)
    for g in gasm:
        print(g["Organism_Name"])
    asmhandle = Entrez.elink(dbfrom="genome",db="assembly", id=genomeID)
    asm = Entrez.read(asmhandle)
    print(asm)
    for a in asm:
        print(a)
#    asmid = 0
#    for lnkset in asm[0]["LinkSetDb"]:
#        for link in lnkset["Link"]:
#            asmid=link["Id"]
#    if not asmid:
#        print("no Assembly ID for genome project %s"%(genomeID))
#        continue
#    print(asmid)
#    asmhandle = Entrez.esummary(db="assembly", id=asmid)
#    asm = Entrez.read(asmhandle)
#    print(asm)
#    genometree = ET.parse(genomehandle)
#    genomeroot = genometree.getroot()
#    print(ET.tostring(genomeroot, encoding='utf8', method='xml'))
