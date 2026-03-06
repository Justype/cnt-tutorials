#!/bin/bash
# Short job that fails with exit code 1. Used to demonstrate --afternotok and --afterany.
# Run from project root: condatainer run src/run_notok.sh
#SBATCH --job-name=job-notok
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:10:00
#SBATCH --output=logs/run_notok_%j.out

mkdir -p logs

echo "Job started at: $(date)"
sleep 30
echo "Job exiting with code 1."
exit 1
