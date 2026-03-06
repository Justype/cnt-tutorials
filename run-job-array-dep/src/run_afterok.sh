#!/bin/bash
# Runs after run_ok.sh succeeds (--afterok). Cancelled if the dependency fails.
# Run from project root: JOB=$(condatainer run src/run_ok.sh) && condatainer run --afterok "$JOB" src/run_afterok.sh
#SBATCH --job-name=after-ok
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:05:00
#SBATCH --output=logs/run_afterok_%j.out

echo "Dependency succeeded. This step runs only when the upstream job exits 0."
