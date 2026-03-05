#!/bin/bash
# Manual launch the script on the host with mpiexec, bypassing condatainer's automatic MPI support.
# Run: sbatch src/slurm/mpi_manual.sh

#SBATCH --job-name=mpi-passthrough
#SBATCH --nodes=3
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB
#SBATCH --time=00:10:00
#SBATCH --output=logs/mpi_manual_%j.out

#DEP: mpi.img

if [ -z "$IN_CONDATAINER" ] && command -v condatainer >/dev/null 2>&1; then
    if [ -n "$SLURM_JOB_ID" ]; then
        FULL_COMMAND=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}' | head -n 1)
        ORIGINAL_SCRIPT_PATH=$(echo "$FULL_COMMAND" | awk '{print $1}')
    else
        ORIGINAL_SCRIPT_PATH=$(realpath "$0")
    fi
    module purge && module load openmpi/4.1.5 && \
        mpiexec condatainer run "$ORIGINAL_SCRIPT_PATH"
    exit $?
fi

# Inside the container (one copy per MPI rank)
echo "NNODES=$NNODES  NTASKS=$NTASKS  MEM_GB=$MEM_GB"

python src/mpi_scatter.py results/manual_passthrough.txt
