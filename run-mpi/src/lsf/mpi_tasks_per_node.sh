#!/bin/bash
# MPI: fixed geometry — ptile pins M tasks per node, total N*M tasks.
# span[ptile=M] makes Nodes derivable as total/-n / ptile.
#BSUB -J mpi-tpn
#BSUB -n 8
#BSUB -R "span[ptile=4] rusage[mem=100]"
#BSUB -W 10
#BSUB -o logs/lsf_mpi_tpn_%J.out

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/lsf_tpn.txt
