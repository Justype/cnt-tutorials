#!/bin/bash
# Trim adapters and low-quality bases with fastp, then run FastQC on trimmed reads.
# Run from project root: condatainer run [--array samples.txt] src/01_trim.sh
#   $1 = SRR accession
#   $2 = condition    (unused here)
#   $3 = cell_line    (unused here)
#SBATCH --job-name=trim
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=1:00:00
#SBATCH --output=logs/01_trim/%x_%A_%a.out
#DEP: fastp/1.1.0
#DEP: fastqc/0.12.1

set -euo pipefail

SRR=$1

# --- Trim ---
if [[ -f "data/fastq-trimmed/${SRR}_1.fastq.gz" && -f "data/fastq-trimmed/${SRR}_2.fastq.gz" ]]; then
    echo "[trim] Skipping ${SRR} because output already exists in data/fastq-trimmed/"
else
    if [[ ! -f "data/fastq/${SRR}_1.fastq.gz" || ! -f "data/fastq/${SRR}_2.fastq.gz" ]]; then
        echo "[trim] ERROR: input FASTQ not found for ${SRR} in data/fastq/"
        exit 1
    fi

    mkdir -p data/fastq-trimmed

    fastp \
        -i "data/fastq/${SRR}_1.fastq.gz" \
        -I "data/fastq/${SRR}_2.fastq.gz" \
        -o "data/fastq-trimmed/${SRR}_1.fastq.gz" \
        -O "data/fastq-trimmed/${SRR}_2.fastq.gz" \
        -w "$NCPUS" \
        --json "data/fastq-trimmed/${SRR}.json" \
        --html "data/fastq-trimmed/${SRR}.html"

    echo "[trim] Done: ${SRR} -> data/fastq-trimmed/${SRR}_1/2.fastq.gz"
fi

# --- FastQC (trimmed) ---
if [[ -f "data/fastq-trimmed/${SRR}_1_fastqc.html" ]]; then
    echo "[fastqc] Skipping ${SRR} trimmed FastQC because output already exists"
else
    fastqc -t "$NCPUS" \
        "data/fastq-trimmed/${SRR}_1.fastq.gz" \
        "data/fastq-trimmed/${SRR}_2.fastq.gz"
    echo "[fastqc] Done: ${SRR} -> data/fastq-trimmed/"
fi
