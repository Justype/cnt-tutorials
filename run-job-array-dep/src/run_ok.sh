#!/bin/bash
# Short job that completes successfully. Used to demonstrate --afterok and --afterany.
# Run from project root: condatainer run src/run_ok.sh
#SBATCH --job-name=job-ok
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:10:00
#SBATCH --output=logs/run_ok_%j.out

mkdir -p logs

echo "Job started at: $(date)"
sleep 30
echo "Job completed successfully."
