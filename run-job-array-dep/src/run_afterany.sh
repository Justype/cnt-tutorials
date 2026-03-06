#!/bin/bash
# Runs after any job finishes regardless of outcome (--afterany).
# Run from project root: JOB=$(condatainer run src/run_ok.sh) && condatainer run --afterany "$JOB" src/run_afterany.sh
#SBATCH --job-name=after-any
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:05:00
#SBATCH --output=logs/run_afterany_%j.out

echo "This step runs after any outcome (success or failure) of the upstream job."
