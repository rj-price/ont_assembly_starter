#!/usr/bin/env bash
#SBATCH -J porechop
#SBATCH --partition=long
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4

# INPUTS
ReadsDir=$1
OutDir=$2
Prefix=$3

# CHECK INPUTS
if [[ -d "$ReadsDir" && -n "$OutDir" && -n "$Prefix" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # RUN PORECHOP
    porechop \
    -t 8 \
    -i "$ReadsDir" \
    -o "$OutDir/$Prefix.fastq.gz"
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a directory containing passed ONT FASTQ files, an output directory and a sample name. \n"
    echo -e "Usage: sbatch 01_porechop.sh <reads_directory> <output_directory> <sample_name> \n"
    exit 1
fi