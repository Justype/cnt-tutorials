#!/bin/bash
# Array job: runs once per line of samples.txt.
# Run from project root: condatainer run --array src/samples.txt src/run_array.sh [extra_arg]
#   $1 = sample name (from samples.txt column 1)
#   $2 = sample value (from samples.txt column 2)
#   extra_arg = any additional arguments passed after the script name
#SBATCH --job-name=process
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:10:00
#SBATCH --output=logs/run_array_%A_%a.out

SAMPLE=$1
shift 1 # Shift the first argument so that $@ now contains only the extra args
SAMPLE_VALUE=$1
shift 1 # Shift again if you want to remove the second argument as well

mkdir -p results

echo "Processing: $SAMPLE with sample value $SAMPLE_VALUE (extra_arg=$@)"
sleep 10
echo "$SAMPLE_VALUE Processed" > "results/${SAMPLE}.txt"
echo "Done at $(date)" >> "results/${SAMPLE}.txt"
echo "[array] Finished: $SAMPLE -> results/${SAMPLE}.txt"
