#!/usr/bin/env bash
#SBATCH -J racon
#SBATCH --partition=medium
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8

# INPUTS
ScriptsDir=$(dirname $0)
Reads=$1
Assembly=$2
Iterations=$3
OutDir=$4

# CHECK INPUTS
if [[ -f "$Reads" && "$Reads" =~ \.(fq|fastq).gz$ && -f "$Assembly" && -n "$Iterations" && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # OUTPUT PREFIX
    Prefix=$(basename "$Assembly" .fasta)

    # RUN RACON
    mkdir -p "$OutDir"/tmp
    cp $Assembly "$OutDir"/tmp/prev.fa

    for i in `seq 1 $Iterations`; do
	echo "Polishing round $i / $Iterations"
	minimap2 -ax map-ont -t 16 "$OutDir"/tmp/prev.fa $Reads > "$OutDir"/tmp/map.sam
	racon --threads 16 $Reads "$OutDir"/tmp/map.sam "$OutDir"/tmp/prev.fa > "$OutDir"/tmp/polished.fa
	mv "$OutDir"/tmp/polished.fa "$OutDir"/tmp/prev.fa
    done

    mv "$OutDir"/tmp/prev.fa "$OutDir"/"$Prefix"_racon.fasta
    rm -rf "$OutDir"/tmp

else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required), a NECAT assembly (.fasta required), a number of iterations (integer) and an output directory. \n"
    echo -e "Usage: sbatch 05_racon.sh <fastq_file.fastq.gz> <assembly.fasta> <number_of_iterations> <output_directory> \n"
    exit 1
fi
