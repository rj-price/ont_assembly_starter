#!/usr/bin/env bash
#SBATCH -J nanoplot
#SBATCH --partition=short
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2

# INPUTS
Reads=$1
OutDir=$2

# CHECK INPUTS
if [[ -f "$Reads" && "$Reads" =~ \.(fq|fastq).gz$ && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # RUN NANOPLOT
    NanoPlot -t 2 --fastq "$Reads" -o "$OutDir"
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required) and an output directory. \n"
    echo -e "Usage: sbatch 02_nanoplot.sh <fastq_file.fastq.gz> <output_directory> \n"
    exit 1
fi
