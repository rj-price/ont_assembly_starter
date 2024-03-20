#!/usr/bin/env bash
#SBATCH -J racon
#SBATCH --partition=medium
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8

# INPUTS
Reads=$1
Assembly=$2
Iterations=$3
OutDir=$4

# CHECK INPUTS
if [[ -d "$ReadsDir" && -n "$Assembly" && -n "$Iterations" && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # OUTPUT PREFIX
    Prefix=$(basename "$Assembly" .fasta)

    # RUN RACON
    /mnt/shared/scratch/jnprice/apps/raconnn/raconnn $Iterations $Reads $Assembly > "$OutDir"/"$Prefix"_racon.fasta

else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required), a minimum read length (in bp), a minimum quality score (integer) and an output directory. \n"
    echo -e "Usage: sbatch racon.sh <fastq_file.fastq.gz> <assembly.fasta> <number of iterations> <output_directory> \n"
    exit 1
fi