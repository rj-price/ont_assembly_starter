# Assembly of Fusarium Genomes

## On NIAB HPC

### Location of raw reads
```
/main/temp-archives/2022_camb_nanopore/Fusarium_new/AJ174/basecalling/pass/
/main/temp-archives/2022_camb_nanopore/Fusarium_new/AJ592/basecalling/pass/
/main/temp-archives/2021_camb_nanopore/Fusarium_new/AJ28/basecalling/pass/
/main/temp-archives/2021_camb_nanopore/Fusarium_new/AJ705/basecalling/pass/
```

### Use Porechop to trim super high accuracy reads
```
for folder in /main/temp-archives/2022_camb_nanopore/Fusarium_new/*;
    do foldershort=$(basename $folder)
    sbatch /home/pricej/scripts/genome_assembly/porechop.sh $folder/basecalling/pass/ /scratch/projects/pricej/fusarium/porechop/$foldershort.fastq
    done

for folder in /main/temp-archives/2021_camb_nanopore/Fusarium_new/*;
    do foldershort=$(basename $folder)
    sbatch /home/pricej/scripts/genome_assembly/porechop.sh $folder/basecalling/pass/ /scratch/projects/pricej/fusarium/porechop/$foldershort.fastq
    done
 ```

### Gzip trimmed fastq files
```
for file in *fastq; do gzip $file; done
```

### Use NanoPlot on new read sets to QC
```
for file in /scratch/projects/pricej/fusarium/porechop/*.fastq.gz;
    do fileshort=$(basename $file | sed s/".fastq.gz"//g)
    sbatch /home/pricej/scripts/genome_assembly/nanoplot_fastq.sh $file /scratch/projects/pricej/fusarium/nanoplot/$fileshort/
    done
```

### Filter out reads under 1kb with Filtlong
```
for file in /scratch/projects/pricej/fusarium/porechop/*.fastq.gz;
    do fileshort=$(basename $file | sed s/".fastq.gz"//g)
    sbatch /home/pricej/scripts/genome_assembly/filtlong_1kb.sh $file $fileshort
    done
```

### Assemble genomes using NECAT
Generate config files
```
for file in /scratch/projects/pricej/fusarium/filtlong/*_1kb.fastq.gz; 
    do bash /home/pricej/scripts/genome_assembly/necat_config.sh $file
    done
```

Edit config files as below
```
PROJECT=<strain>
ONT_READ_LIST=read_list.txt
GENOME_SIZE=50000000
THREADS=16
```

Run assembly
```
sbatch /home/pricej/scripts/genome_assembly/necat.sh {config}
```

## On Crop Diversity HPC

### Transfer everything to Crop Diversity HPC
```
rsync -avP /scratch/projects/pricej/fusarium/ jnprice@gruffalo.cropdiversity.ac.uk:/mnt/shared/scratch/jnprice/fusarium
```

### Polish NECAT assemblies with long reads using Racon 
x1
```
for file in /mnt/shared/scratch/jnprice/fusarium/necat/*.fasta; 
    do fileshort=$(basename $file | sed s/".fasta"//g)
    sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/racon.sh 1 /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
    done
```

x2
```
for file in /mnt/shared/scratch/jnprice/fusarium/necat/*.fasta; 
    do fileshort=$(basename $file | sed s/".fasta"//g)
    sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/racon.sh 2 /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
    done
```

x3
```
for file in /mnt/shared/scratch/jnprice/fusarium/necat/*.fasta; 
    do fileshort=$(basename $file | sed s/".fasta"//g)
    sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/racon.sh 3 /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
    done
```

### Polish x1 Racon assemblies with Medaka
```
for file in /mnt/shared/scratch/jnprice/fusarium/racon_x1/*_racon.fasta; 
    do fileshort=$(basename $file | sed s/"_racon.fasta"//g)
    sbatch /mnt/shared/scratch/jnprice/private/scripts/genome_assembly/medaka.sh /mnt/shared/scratch/jnprice/fusarium/filtlong/"$fileshort"_1kb.fastq.gz $file
    done
```

### Purge haplotigs from assemblies with purge_dups
```
for file in /mnt/shared/scratch/jnprice/fusarium/filtlong/*_1kb.fastq.gz;
    do fileshort=$(basename $file | sed s/"_1kb.fastq.gz"//g)
    sbatch ~/scratch/private/scripts/genome_assembly/purge_dups.sh /mnt/shared/scratch/jnprice/fusarium/medaka/"$fileshort"*.fasta $file
    done
```

### QC with BUSCO at each stage of assembly process
```
for file in *fasta;
    do sbatch /mnt/shared/scratch/jnprice/private/scripts/busco_hypocreales.sh $file;
    done
```
