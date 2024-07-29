# ont_assembly_starter

## Getting Started

### Installation
Installing the analysis environment requires conda to be installed first.

To install the pipeline:
```bash
# Get pipeline
git clone https://github.com/rj-price/ont_assembly_starter.git 
# Change to directory
cd ont_assembly_starter
# Create conda environment with all dependencies
conda env create -f environment.yml
# Activate environment
conda activate ont_assembly
```

### Input
This assembly pipeline processes Oxford Nanopore long-read data.

### Output
The main output from this pipeline is a long-read only assembly with quality metrics.

<br>

# Genome Assembly of ONT data

Environmental variable (change this to actual path):
```bash
scripts_dir=/dir/to/ont_assembly_starter/scripts
```

## Porechop
**Used to trim sequencing adapters from ONT reads.**

Set the reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/reads
out_dir=/dir/to/output
```

To run on a directory of reads:
```bash
sbatch "$scripts_dir"/01_porechop.sh \
    "$reads_dir" \
    "$out_dir" \
    sample_name
```

## NanoPlot
**Used to produce read QC metrics and plots.**

Set the trimmed reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/porechop_out
out_dir=/dir/to/output
```

To run on a single trimmed reads file:
```bash
sbatch "$scripts_dir"/02_nanoplot.sh \
    "$reads_dir"/sample_name.fastq.gz \
    "$out_dir"
```

## Filtlong
**Used to remove reads under a specified read length and quality score.**

Set the trimmed reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/porechop_out
out_dir=/dir/to/output
```

To run on a single reads file with a minimum read length of 1kb and a minimum quality score of Q12:
```bash
sbatch "$scripts_dir"/03_filtlong.sh \
    "$reads_dir"/sample_name.fastq.gz \
    1000 \
    12 \
    "$out_dir"
```

## NECAT
**Used to correct and assemble ONT reads into contigs.**

Set the filtered reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/filtlong_out
out_dir=/dir/to/output
```

Run assembly for 16Mb genome:
```bash
sbatch "$scripts_dir"/04_necat.sh \
    "$reads_dir"/sample_name.fastq.gz \
    16000000 \
    "$out_dir"
```

## Racon 
**Used to polish NECAT assemblies with long reads.**

Set the filtered reads, NECAT assembly and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/filtlong_out
necat_dir=/dir/to/necat_out
out_dir=/dir/to/output
```

Run on NECAT assembly with one iteration:
```bash
sbatch "$scripts_dir"/05_racon.sh \
    "$reads_dir"/sample_name.fastq.gz \
    "$necat_dir"/sample_name_necat.fasta \
    1 \
    "$out_dir"
```

## Medaka
**Used to polish Racon assemblies with long reads.**

Set the filtered reads, Racon assembly and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/filtlong_out
racon_dir=/dir/to/racon_out
out_dir=/dir/to/output
```

Run on Racon assembly:
```bash
sbatch "$scripts_dir"/06_medaka.sh \
    "$reads_dir"/sample_name.fastq.gz \
    "$racon_dir"/sample_name_necat_racon.fasta \
    "$out_dir"
```

## Assembly QC

### BUSCO
**Used as a quality control step to check number of conserved single copy orthologs present in assembly.**

Set the assembly and output directories (change these to the actual paths):
```bash
medaka_dir=/dir/to/medaka_out
out_dir=/dir/to/output
```

Run on assembly file with the lineage fungi:
```bash
sbatch "$scripts_dir"/XX_busco.sh \
    "$medaka_dir"/sample_name_necat_racon_medaka.fasta \
    fungi \
    "$out_dir"
```

<br>

### GFASTATS
**Used as an assembly quality control step to check number of contigs, assembly size. contigs N50, etc.**

Set the assembly and output directories (change these to the actual paths):
```bash
medaka_dir=/dir/to/medaka_out
out_dir=/dir/to/output
```

Run on assembly file:
```bash
sbatch "$scripts_dir"/XX_gfastats.sh \
    "$medaka_dir"/sample_name_necat_racon_medaka.fasta \
    "$out_dir"
```

<br>

# OR...

## Run full ONT pipeline

Set the reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/reads
out_dir=/dir/to/output
```

Run full ONT assembly pipeline for 16Mb genome:
```bash
sbatch "$scripts_dir"/00_assembly.sh \
    "$reads_dir" \
    16000000 \
    "$out_dir"
```
