#!/bin/bash
# Merge per-sample quant.sf files into a TPM matrix.
# Run from project root: condatainer run src/03_collect.sh
# Build the overlay first: condatainer create -p src/overlay/r-collect -f src/overlay/r-collect.yml

#SBATCH --job-name=collect
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=0:30:00
#SBATCH --output=logs/03_collect_%j.log
#DEP: src/overlay/r-collect.sqf
#DEP: grch38/gtf-gencode/47

set -euo pipefail

if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [samples.txt]"
    exit 1
fi

SAMPLES=${1:-metadata/samples.txt}

if [[ ! -d "data/quants" ]]; then
    echo "[collect] ERROR: data/quants/ directory not found. Please run 02_quant.sh first."
    exit 1
fi

Rscript src/r/collect.R "$SAMPLES"
