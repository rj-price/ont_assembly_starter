#!/usr/bin/env bash
#SBATCH -J busco
#SBATCH --partition=medium
#SBATCH --mem=4G
#SBATCH --cpus-per-task=8

# INPUTS
Assembly=$1
Lineage=$2
OutDir=$3

# CHECK INPUTS
if [[ -f "$Assembly" && -n "$Lineage" && -n "$OutDir" ]]; then
    # CREATE OUTPUT FOLDER
    mkdir -p "$OutDir"

    # RUN BUSCO
    busco -m genome -c 8 -i "$Assembly" -o "$OutDir" -l "$Lineage"_odb10

else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide an assembly file (.fasta required), a BUSCO lineage (see https://busco.ezlab.org/list_of_lineages.html) and an output directory. \n"
    echo -e "Usage: sbatch XX_busco.sh <assembly.fasta> <busco_lineage> <output_directory> \n"
    exit 1
fi