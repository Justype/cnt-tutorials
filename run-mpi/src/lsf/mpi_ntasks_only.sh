#!/bin/bash
# MPI: free-distribution — LSF placing N tasks across available hosts.
# No span[] constraint; Nodes cannot be derived.
#BSUB -J mpi-ntasks
#BSUB -n 8
#BSUB -R "rusage[mem=100]"
#BSUB -W 10
#BSUB -o logs/lsf_mpi_ntasks_%J.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/lsf_ntasks.txt
