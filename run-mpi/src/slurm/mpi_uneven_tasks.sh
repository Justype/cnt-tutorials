#!/bin/bash
# MPI: fixed geometry — explicit nodes + tasks-per-node.
# --mem is per-node, valid because --nodes is specified.
#SBATCH --job-name=mpi-tpn
#SBATCH --ntasks=8
#SBATCH --nodes=3
#SBATCH --mem=1GB
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm_mpi_uneven_tasks_%j.out

#DEP: mpi.img

echo "=== Normalized Environment Variables ==="
echo "NNODES=$NNODES  NTASKS=$NTASKS  NTASKS_PER_NODE=$NTASKS_PER_NODE  OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "=== SLURM Native Variables (task-local) ==="
echo "SLURM_JOB_NUM_NODES=$SLURM_JOB_NUM_NODES"
echo "SLURM_NTASKS=$SLURM_NTASKS"
echo "SLURM_NTASKS_PER_NODE=$SLURM_NTASKS_PER_NODE"
echo "SLURM_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK"
echo "SLURM_NODEID=$SLURM_NODEID"
echo "SLURM_PROCID=$SLURM_PROCID"
echo "SLURM_LOCALID=$SLURM_LOCALID"
echo "=== Open MPI Environment Variables (global/local) ==="
echo "OMPI_COMM_WORLD_SIZE=$OMPI_COMM_WORLD_SIZE        (global: total tasks)"
echo "OMPI_COMM_WORLD_RANK=$OMPI_COMM_WORLD_RANK        (global: task rank)"
echo "OMPI_COMM_WORLD_LOCAL_SIZE=$OMPI_COMM_WORLD_LOCAL_SIZE  (local: tasks on this node)"
echo "OMPI_COMM_WORLD_LOCAL_RANK=$OMPI_COMM_WORLD_LOCAL_RANK  (local: rank on this node)"
echo "OMPI_COMM_WORLD_NODE_RANK=$OMPI_COMM_WORLD_NODE_RANK   (node: rank within node)"
echo ""

python src/mpi_scatter.py results/slurm_uneven_tasks.txt
