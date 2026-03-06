#!/bin/bash
# Runs after run_notok.sh fails (--afternotok). Cancelled if the dependency succeeds.
# Run from project root: JOB=$(condatainer run src/run_notok.sh) && condatainer run --afternotok "$JOB" src/run_afternotok.sh
#SBATCH --job-name=after-notok
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:05:00
#SBATCH --output=logs/run_afternotok_%j.out

echo "Dependency failed. This step runs only when the upstream job exits non-zero."
