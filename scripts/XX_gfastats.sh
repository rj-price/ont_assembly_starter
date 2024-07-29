#!/usr/bin/env bash
#SBATCH -J gfastats
#SBATCH --partition=short
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1

# INPUTS
Assembly=$1
OutDir=$2

# CHECK INPUTS
if [[ -f "$Assembly" && -n "$OutDir" ]]; then
    Prefix=$(basename $Assembly .fasta)

    # RUN GFASTATS
    gfastats $Assembly --tabular > "$OutDir"/"$Prefix"_genome_stats.tsv
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide an assembly file (.fasta required) and an output directory. \n"
    echo -e "Usage: sbatch XX_gfastats.sh <assembly.fasta> <output_directory> \n"
    exit 1
fi
