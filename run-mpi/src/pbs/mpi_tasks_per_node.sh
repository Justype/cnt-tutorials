#!/bin/bash
# MPI: fixed geometry — N nodes, M tasks per node.
# select=N:ncpus=M:mpiprocs=M requests M MPI ranks on each of N nodes.
#PBS -N mpi-tpn
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=1gb
#PBS -l walltime=00:10:00
#PBS -o logs/pbs_mpi_tpn.out
#PBS -j oe

#DEP: mpi.img

echo "NNODES=$NNODES  NTASKS=$NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"

python src/mpi_scatter.py results/pbs_tpn.txt
