#!/usr/bin/env bash
#SBATCH -J filtlong
#SBATCH --partition=medium
#SBATCH --mem=5G
#SBATCH --cpus-per-task=8

# INPUTS
Reads=$1
MinLength=$2
MinQual=$3
OutDir=$4

# CHECK INPUTS
if [[ -f "$Reads" && "$Reads" =~ \.(fq|fastq).gz$ && -n "$MinLength" && -n "$MinQual" && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # CALCULATE QUALITY PERCENTAGE
    QualPercent=$(awk "BEGIN { printf \"%.10f\", 1 - (10 ^ (-($MinQual / 10))) }")

    # OUTPUT PREFIX
    Prefix=$(basename "$Reads" .fastq.gz)

    # OUTPUT SUFFIX
    KB=$(($MinLength / 1000))

    # RUN FILTLONG
    filtlong --min_length $MinLength --min_mean_q $QualPercent $Reads | gzip > "$Prefix"_"$KB"kb_Q"$MinQual".fastq.gz
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required), a minimum read length (in bp), a minimum quality score (integer) and an output directory. \n"
    echo -e "Usage: sbatch 03_filtlong.sh <fastq_file.fastq.gz> <minimum_read_length> <minimum_quality_score> <output_directory> \n"
    exit 1
fi