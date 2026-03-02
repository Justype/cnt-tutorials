#!/bin/bash
# Trim adapters with Trim Galore (auto-detects TruSeq/Nextera adapters via Cutadapt).
# Run from project root: condatainer run [--array samples.txt] src/01_trim_galore.sh
#   $1 = SRR accession
#   $2 = condition    (unused here)
#   $3 = cell_line    (unused here)
#SBATCH --job-name=trim
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=1:00:00
#SBATCH --output=logs/01_trim/%x_%A_%a.out
#DEP: trim-galore/0.6.11
#DEP: fastqc/0.12.1

set -euo pipefail

SRR=$1

if [[ -f "data/fastq-trim-galore/${SRR}_1.fastq.gz" && -f "data/fastq-trim-galore/${SRR}_2.fastq.gz" ]]; then
    echo "[trim] Skipping ${SRR} because output already exists in data/fastq-trim-galore/"
    exit 0
fi

if [[ ! -f "data/fastq/${SRR}_1.fastq.gz" || ! -f "data/fastq/${SRR}_2.fastq.gz" ]]; then
    echo "[trim] ERROR: input FASTQ not found for ${SRR} in data/fastq/"
    exit 1
fi

mkdir -p data/fastq-trim-galore

trim_galore \
    --paired \
    --cores "$NCPUS" \
    -o data/fastq-trim-galore/ \
    "data/fastq/${SRR}_1.fastq.gz" \
    "data/fastq/${SRR}_2.fastq.gz"

# Rename to consistent naming expected by 02_quant.sh
mv "data/fastq-trim-galore/${SRR}_1_val_1.fq.gz" "data/fastq-trim-galore/${SRR}_1.fastq.gz"
mv "data/fastq-trim-galore/${SRR}_2_val_2.fq.gz" "data/fastq-trim-galore/${SRR}_2.fastq.gz"

echo "[trim] Done: ${SRR} -> data/fastq-trim-galore/${SRR}_1/2.fastq.gz"

# --- FastQC (trimmed) ---
if [[ -f "data/fastq-trim-galore/${SRR}_1_fastqc.html" ]]; then
    echo "[fastqc] Skipping ${SRR} trimmed FastQC because output already exists"
else
    fastqc -t "$NCPUS" \
        "data/fastq-trim-galore/${SRR}_1.fastq.gz" \
        "data/fastq-trim-galore/${SRR}_2.fastq.gz"
    echo "[fastqc] Done: ${SRR} -> data/fastq-trim-galore/"
fi
