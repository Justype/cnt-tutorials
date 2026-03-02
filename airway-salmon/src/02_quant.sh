#!/bin/bash
# Quantify transcript abundances with Salmon (mapping-based mode).
# Run from project root: condatainer run [--array samples.txt] src/02_quant.sh
#   $1 = SRR accession
#   $2 = condition    (unused here)
#   $3 = cell_line    (unused here)
#SBATCH --job-name=salmon-quant
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=1:00:00
#SBATCH --output=logs/02_quant/%x_%A_%a.out
#DEP: salmon/1.10.2
#DEP: grch38/salmon/1.10.2/gencode47

set -euo pipefail

SRR=$1

if [[ -d "data/quants/${SRR}" ]]; then
    echo "[quant] Skipping ${SRR} because output already exists in data/quants/"
    exit 0
fi

if [[ ! -f "data/fastq-trimmed/${SRR}_1.fastq.gz" || ! -f "data/fastq-trimmed/${SRR}_2.fastq.gz" ]]; then
    echo "[quant] ERROR: input FASTQ not found for ${SRR} in data/fastq-trimmed/"
    exit 1
fi

mkdir -p data/quants

# $SALMON_INDEX_DIR is set automatically by the grch38/salmon/1.10.2/gencode47 overlay
salmon quant \
    -i "$SALMON_INDEX_DIR" \
    -l A \
    -p "$NCPUS" \
    -1 "data/fastq-trimmed/${SRR}_1.fastq.gz" \
    -2 "data/fastq-trimmed/${SRR}_2.fastq.gz" \
    --validateMappings \
    -o "data/quants/${SRR}"

echo "[quant] Done: ${SRR} -> data/quants/${SRR}/quant.sf"
