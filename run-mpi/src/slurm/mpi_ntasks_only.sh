#!/bin/bash
# MPI: free-distribution — SLURM places tasks across nodes freely.
# No --nodes, so --mem-per-cpu is required instead of --mem.
#SBATCH --job-name=mpi-ntasks
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=100m
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm_mpi_ntasks_%j.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/slurm_ntasks.txt
