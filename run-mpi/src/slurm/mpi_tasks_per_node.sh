#!/bin/bash
# MPI: fixed geometry — explicit nodes + tasks-per-node.
# --mem is per-node, valid because --nodes is specified.
#SBATCH --job-name=mpi-tpn
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=1GB
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm_mpi_tpn_%j.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/slurm_tpn.txt
