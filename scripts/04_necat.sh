#!/usr/bin/env bash
#SBATCH -J necat
#SBATCH --partition=long
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8

# INPUTS
Reads=$1
GenomeSize=$2
OutDir=$3

# CHECK INPUTS
if [[ -f "$Reads" && "$Reads" =~ \.(fq|fastq).gz$ && -n "$GenomeSize" && -n "$OutDir" ]]; then
    # OUTPUT PREFIX
    Prefix=$(basename "$Reads" .fastq.gz)

    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # CREATE READ LIST FILE
    realpath "$Reads" > "$OutDir"/read_list.txt

    # CREATE NECAT CONFIG FILE
    necat config "$OutDir"/config.txt

    # EDIT CONFIG FILE
    sed -i "s/PROJECT=/PROJECT=$Prefix/g" $OutDir/config.txt
    sed -i 's/ONT_READ_LIST=/ONT_READ_LIST=read_list.txt/g' $OutDir/config.txt
    sed -i "s/GENOME_SIZE=/GENOME_SIZE=$GenomeSize/g" $OutDir/config.txt
    sed -i 's/THREADS=4/THREADS=16/g' $OutDir/config.txt

    # RUN NECAT
    cd "$OutDir"
    necat correct config.txt
    necat assemble config.txt 
    necat bridge config.txt

    # COPY FINAL ASSEMBLY
    cp $Prefix/6-bridge_contigs/polished_contigs.fasta $OutDir/"$Prefix"_necat.fasta
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide a FASTQ file (.fq.gz or .fastq.gz required), an estimated genome length (in bp) and an output directory. \n"
    echo -e "Usage: sbatch 04_necat.sh <fastq_file.fastq.gz> <estimated_genome_size> <output_directory> \n"
    exit 1
fi
