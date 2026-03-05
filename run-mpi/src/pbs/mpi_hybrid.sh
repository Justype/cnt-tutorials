#!/bin/bash
# Hybrid MPI+OpenMP: M MPI ranks per node, each with T OpenMP threads.
# ncpus = mpiprocs * ompthreads; ompthreads is passed to OMP_NUM_THREADS.
#PBS -N mpi-hybrid
#PBS -l select=2:ncpus=8:mpiprocs=4:ompthreads=2:mem=2gb
#PBS -l walltime=00:10:00
#PBS -o logs/pbs_mpi_hybrid.out
#PBS -j oe

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/pbs_hybrid.txt
