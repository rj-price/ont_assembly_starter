#!/usr/bin/env bash
#SBATCH -J ont_assembly
#SBATCH --partition=medium
#SBATCH --mem=60G
#SBATCH --cpus-per-task=10

# INPUTS
ReadsDir=$1
GenomeSize=$2
OutDir=$3

echo "**********************************************************************************"
echo "Running pipeline with the following inputs:"
echo "Reads Directory: $ReadsDir"
echo "Estimated Genome Size: $GenomeSize"
echo "Output Directory: $OutDir"
echo ""

# PREPARE OUTDIR
echo "**********************************************************************************"
echo " Preparing directory structure"

Prefix=$(basename $ReadsDir)
mkdir -p $OutDir/$Prefix
mkdir -p $OutDir/$Prefix/nanoplot
mkdir -p $OutDir/$Prefix/necat
mkdir -p $OutDir/$Prefix/longpolish
mkdir -p $OutDir/$Prefix/final

echo ""

# PORECHOP
echo "**********************************************************************************"
echo "Running Porechop with the following parameters:"
echo "Reads Directory: $ReadsDir"
echo "Output: $OutDir/$Prefix/$Prefix.fastq.gz"

porechop -t 12 -i $ReadsDir -o $OutDir/$Prefix/$Prefix.fastq.gz

echo "Porechop Complete"
echo ""

# NANOPLOT
echo "**********************************************************************************"
echo "Running NanoPlot with the following parameters:"
echo "Input: $OutDir/$Prefix/$Prefix.fastq.gz"
echo "Output: $OutDir/$Prefix/nanoplot"

NanoPlot -t 2 --fastq $OutDir/$Prefix/$Prefix.fastq.gz -o $OutDir/$Prefix/nanoplot

echo "NanoPlot Complete"
echo ""

# FILTLONG (1kb Q10)
echo "**********************************************************************************"
echo "Running FiltLong with the following parameters:"
echo "Input: $OutDir/$Prefix/$Prefix.fastq.gz"
echo "Output: $OutDir/$Prefix/{$Prefix}_filt.fastq.gz"

filtlong --min_length 1000 --min_mean_q 90 $OutDir/$Prefix/$Prefix.fastq.gz | gzip > $OutDir/$Prefix/"$Prefix"_filt.fastq.gz

echo "FiltLong Complete"
echo ""

# NECAT
echo "**********************************************************************************"
echo "Running NECAT with the following parameters:"
echo "Input: $OutDir/$Prefix/{$Prefix}_filt.fastq.gz"
echo "Output: $OutDir/$Prefix/necat/{$Prefix}_necat.fasta"

realpath $OutDir/$Prefix/"$Prefix"_filt.fastq.gz > $OutDir/$Prefix/necat/read_list.txt
necat config $OutDir/$Prefix/necat/"$Prefix"_config.txt

sed -i "s/PROJECT=/PROJECT=$Prefix/g" $OutDir/$Prefix/necat/"$Prefix"_config.txt
sed -i 's/ONT_READ_LIST=/ONT_READ_LIST=read_list.txt/g' $OutDir/$Prefix/necat/"$Prefix"_config.txt
sed -i "s/GENOME_SIZE=/GENOME_SIZE=$GenomeSize/g" $OutDir/$Prefix/necat/"$Prefix"_config.txt
sed -i 's/THREADS=4/THREADS=16/g' $OutDir/$Prefix/necat/"$Prefix"_config.txt

cd $OutDir/$Prefix/necat

necat correct $OutDir/$Prefix/necat/"$Prefix"_config.txt \
    && necat assemble $OutDir/$Prefix/necat/"$Prefix"_config.txt \
    && necat bridge $OutDir/$Prefix/necat/"$Prefix"_config.txt

cp $OutDir/$Prefix/necat/$Prefix/6-bridge_contigs/polished_contigs.fasta $OutDir/$Prefix/necat/"$Prefix"_necat.fasta

echo "NECAT Complete"
echo ""

# LONGPOLISH
# Racon (x1)
echo "**********************************************************************************"
echo "Running Racon with the following parameters:"
echo "Input: $OutDir/$Prefix/{$Prefix}_filt.fastq.gz"
echo "Input: $OutDir/$Prefix/necat/{$Prefix}_necat.fasta"
echo "Output: $OutDir/$Prefix/longpolish/{$Prefix}_racon.fasta"

cd $OutDir/$Prefix/longpolish

minimap2 -ax map-ont -t 16 $OutDir/$Prefix/necat/"$Prefix"_necat.fasta $OutDir/$Prefix/"$Prefix"_filt.fastq.gz > $OutDir/$Prefix/longpolish/map.sam
racon --threads 16 $OutDir/$Prefix/"$Prefix"_filt.fastq.gz $OutDir/$Prefix/longpolish/map.sam $OutDir/$Prefix/necat/"$Prefix"_necat.fasta > $OutDir/$Prefix/longpolish/"$Prefix"_racon.fasta

echo "Racon Complete"
echo ""

# Medaka (x1)
echo "**********************************************************************************"
echo "Running Medaka with the following parameters:"
echo "Input: $OutDir/$Prefix/{$Prefix}_filt.fastq.gz"
echo "Input: $OutDir/$Prefix/longpolish/{$Prefix}_racon.fasta"
echo "Output: $OutDir/$Prefix/final/{$Prefix}_medaka.fasta"

medaka_consensus \
    -i $OutDir/$Prefix/"$Prefix"_filt.fastq.gz \
    -d $OutDir/$Prefix/longpolish/"$Prefix"_racon.fasta \
    -o $OutDir/$Prefix/longpolish \
    -t 12 -m r941_min_high_g360

cp $OutDir/$Prefix/longpolish/consensus.fasta $OutDir/$Prefix/final/"$Prefix"_medaka.fasta

echo "Medaka Complete"
echo ""

# QC
# BUSCO
echo "**********************************************************************************"
echo "Running BUSCO with the following parameters:"
echo "Input: $OutDir/$Prefix/final/{$Prefix}_medaka.fasta"
echo "Output: $OutDir/$Prefix/final/BUSCO_{$Prefix}.fungi"

cd $OutDir/$Prefix/final

busco -m genome -c 8 -i $OutDir/$Prefix/final/"$Prefix"_medaka.fasta -o BUSCO_"$Prefix".fungi -l ~/busco_downloads/lineages/fungi_odb10

conda deactivate

echo "BUSCO Complete"
echo ""

# Stats
echo "**********************************************************************************"
echo "Running GFAStats with the following parameters:"
echo "Input: $OutDir/$Prefix/final/{$Prefix}_medaka.fasta"

gfastats $OutDir/$Prefix/final/"$Prefix"_medaka.fasta $GenomeSize --threads 4 --tabular --nstar-report > $OutDir/$Prefix/final/"$Prefix"_genome_stats.tsv

echo "GFAStats Complete"
echo ""

echo "**********************************************************************************"
echo "**********************************************************************************"
echo "                    P I P E L I N E    C O M P L E T E"
echo "**********************************************************************************"
echo "**********************************************************************************"
