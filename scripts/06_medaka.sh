#!/usr/bin/env bash
#SBATCH -J medaka
#SBATCH --partition=medium
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8


# INPUTS
Reads=$1
Assembly=$2
OutDir=$3

# CHECK INPUTS
if [[ -f "$Reads" && "$Reads" =~ \.(fq|fastq).gz$ && -f "$Assembly" && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # OUTPUT PREFIX
    Prefix=$(basename "$Assembly" .fasta)

    # RUN RACON
    medaka_consensus \
        -i $Reads \
        -d $Assembly \
        -o $OutDir \
        -t 16 -m r941_min_high_g360

    mv $OutDir/consensus.fasta $OutDir/"$Prefix"_medaka.fasta
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required), a Racon assembly (.fasta required) and an output directory. \n"
    echo -e "Usage: sbatch 06_medaka.sh <fastq_file.fastq.gz> <assembly.fasta> <output_directory> \n"
    exit 1
fi
