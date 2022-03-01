#!/usr/bin/env bash
#SBATCH -J porechop
#SBATCH --partition=long
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16

# reads_dir = $1
# output = $2

/home/pricej/programs/Porechop/porechop-runner.py \
    -i $1 \
    -o $2
