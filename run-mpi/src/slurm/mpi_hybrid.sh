#!/bin/bash
# Hybrid MPI+OpenMP: each MPI rank spawns multiple OpenMP threads.
# OMP_NUM_THREADS is set automatically CPUs per task by condatainer.
#SBATCH --job-name=mpi-hybrid
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --mem=2GB
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm_mpi_hybrid_%j.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/slurm_hybrid.txt
