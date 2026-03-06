#!/bin/bash
# Demonstrate passing arguments to condatainer run.
# Run from project root: condatainer run src/run_arg.sh [args...]
#SBATCH --job-name=run-arg
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:05:00
#SBATCH --output=logs/run_arg_%j.out

echo "Script received $# argument(s): $*"
for i in $(seq 1 $#); do
    echo "  \$$i = ${!i}"
done
