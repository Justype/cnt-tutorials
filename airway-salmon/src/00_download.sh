#!/bin/bash
# Download paired-end FASTQ from SRA and run FastQC on raw reads.
# Run from project root: condatainer run [--array samples.txt] src/00_download.sh
#   $1 = SRR accession
#   $2 = condition    (unused here)
#   $3 = cell_line    (unused here)
#SBATCH --job-name=download
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --output=logs/00_download/%x_%A_%a.out
#DEP: parallel-fastq-dump/0.6.7
#DEP: fastqc/0.12.1

set -euo pipefail

SRR=$1

# --- Download ---
if [[ -f "data/fastq/${SRR}_1.fastq.gz" && -f "data/fastq/${SRR}_2.fastq.gz" ]]; then
    echo "[download] Skipping ${SRR} because output already exists in data/fastq/"
else
    mkdir -p data/fastq tmp

    cleanup() {
        local rc=$?
        if [[ $rc -ne 0 ]]; then
            echo "[download] Failed (exit $rc), removing partial files for ${SRR}..."
            rm -f "data/fastq/${SRR}"_*.fastq.gz
        fi
        exit $rc
    }
    trap cleanup EXIT

    parallel-fastq-dump \
        --sra-id "$SRR" \
        --threads "$NCPUS" \
        --outdir data/fastq/ \
        --tmpdir tmp/ \
        --split-files \
        --gzip

    trap - EXIT
    echo "[download] Done: ${SRR} -> data/fastq/${SRR}_1/2.fastq.gz"
fi

# --- FastQC (raw) ---
if [[ -f "data/fastq/${SRR}_1_fastqc.html" ]]; then
    echo "[fastqc] Skipping ${SRR} raw FastQC because output already exists"
else
    fastqc -t "$NCPUS" \
        "data/fastq/${SRR}_1.fastq.gz" \
        "data/fastq/${SRR}_2.fastq.gz"
    echo "[fastqc] Done: ${SRR} -> data/fastq/"
fi
