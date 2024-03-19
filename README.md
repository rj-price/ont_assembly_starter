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
sbatch "$scripts_dir"/porechop.sh \
    "$reads_dir" \
    "$out_dir" \
    sample_name
```

## NanoPlot
**Used to produce QC metrics and plots.**

Set the trimmed reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/porechop_out
out_dir=/dir/to/output
```

To run on a single trimmed reads file:
```bash
sbatch "$scripts_dir"/nanoplot.sh \
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
sbatch "$scripts_dir"/filtlong.sh \
    "$reads_dir"/sample_name.fastq.gz \
    1000 \
    12 \
    "$out_dir"
```

## NECAT
**Used to correct and assemble ONT reads into contigs.**

Set the trimmed reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/filtlong_out
out_dir=/dir/to/output
```

Run assembly for 16Mb genome:
```bash
sbatch "$scripts_dir"/necat.sh \
    "$reads_dir"/sample_name.fastq.gz \
    16000000 \
    "$out_dir"
```

### Polish NECAT assemblies with long reads using Racon 
x3
```
sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/racon.sh 3 /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
```

### Polish x1 Racon assemblies with Medaka
```
sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/medaka.sh /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
```

### QC with BUSCO at each stage of assembly process
```
sbatch /mnt/shared/scratch/jnprice/private/scripts/busco_hypocreales.sh $file;
```

## Optional:

### Purge haplotigs from assemblies with purge_dups
```
sbatch ~/scratch/private/scripts/genome_assembly/purge_dups.sh /mnt/shared/scratch/jnprice/fusarium/medaka/"$fileshort"*.fasta $file
```

### Polish with Illumina data


# OR...

## Run full ONT pipeline

Set the reads and output directories (change these to the actual paths):
```bash
reads_dir=/dir/to/reads
out_dir=/dir/to/output
```

Run full ONT assembly pipeline for 16Mb genome:
```bash
sbatch "$scripts_dir"/assembly.sh \
    "$reads_dir" \
    16000000 \
    "$out_dir"
```