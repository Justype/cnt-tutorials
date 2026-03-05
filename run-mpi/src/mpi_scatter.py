#!/usr/bin/env python3
"""
MPI scatter/gather example using mpi4py.

Usage: python src/mpi_scatter.py [output_path]
  output_path  Path for the results file (default: results/output.txt)

Run via mpi_manual.sh or other scheduler scripts — do not call directly.
"""
import os
import sys
import socket
from mpi4py import MPI

output_path = sys.argv[1] if len(sys.argv) > 1 else "results/output.txt"

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
hostname = socket.gethostname()

# ---------------------------------------------------------
# Step 1: Rank 0 reads the task file and divides into chunks
# ---------------------------------------------------------
if rank == 0:
    print(f"[rank 0 on {hostname}] Reading tasks.txt ({size} ranks total), output -> {output_path}")
    with open("tasks.txt") as f:
        all_tasks = [line.strip() for line in f if line.strip()]

    chunk_size = len(all_tasks) // size
    chunks = [all_tasks[i : i + chunk_size] for i in range(0, len(all_tasks), chunk_size)]
else:
    chunks = None

# ---------------------------------------------------------
# Step 2: Scatter one chunk to each rank
# ---------------------------------------------------------
my_tasks = comm.scatter(chunks, root=0)

# ---------------------------------------------------------
# Step 3: Each rank processes its tasks
# ---------------------------------------------------------
my_results = [f"[{hostname} rank {rank}] processed: {t}" for t in my_tasks]

# ---------------------------------------------------------
# Step 4: Gather results back to rank 0
# ---------------------------------------------------------
all_results = comm.gather(my_results, root=0)

# ---------------------------------------------------------
# Step 5: Rank 0 writes the output file
# ---------------------------------------------------------
if rank == 0:
    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "w") as f:
        for worker_results in all_results:
            for line in worker_results:
                f.write(line + "\n")
    print(f"Done! Results written to {output_path}")
