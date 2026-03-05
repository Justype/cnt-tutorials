#!/bin/bash
# Hybrid MPI+OpenMP: M MPI ranks per node, each rank gets T CPU cores.
# affinity[cores(T)] pins T cores per task; -n = total_nodes * tasks_per_node.
#BSUB -J mpi-hybrid
#BSUB -n 8
#BSUB -R "span[ptile=4] affinity[cores(2)] rusage[mem=500]"
#BSUB -W 10
#BSUB -o logs/lsf_mpi_hybrid_%J.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/lsf_hybrid.txt
