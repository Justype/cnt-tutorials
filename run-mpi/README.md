# MPI with CondaTainer

A tutorial for running MPI, and hybrid MPI+OpenMP jobs (mpi4py) with a CondaTainer workspace overlay.

The example uses an MPI scatter/gather pattern: rank 0 reads `tasks.txt`, distributes tasks evenly across all ranks, each rank processes its chunk, and results are gathered back and written to `results/`.

## When to Use MPI vs Threads

**Most jobs should use threads (CPUs), not MPI tasks.**

Multiple tasks launch multiple independent copies of your program (MPI ranks). Unless your code explicitly calls `from mpi4py import MPI` and uses `MPI.COMM_WORLD`, extra tasks waste allocation.

| Use Case | Correct Resource |
|----------|-----------------|
| Python/R script, parallelised with threads/joblib | `--cpus-per-task=N` (OpenMP) |
| True MPI program with `MPI_Init` / `mpi4py` | `--ntasks` / `--ntasks-per-node` (MPI) |
| MPI ranks each using multiple threads | both (Hybrid) |

## Prerequisites

- [CondaTainer](https://github.com/Justype/condatainer) installed
- A scheduler with an OpenMPI module available (`ml av openmpi`)

## Setup (run once on the login node)

```bash
# 1. Create a sparse writable workspace overlay for this project
condatainer overlay create --sparse mpi.img

# 2. Find the OpenMPI version on your cluster
ml av openmpi
# Example output: openmpi/4.1.5

# 3. Install mpi4py and a matching openmpi inside the overlay
#    Use the same major.minor version (e.g., 4.1)
condatainer e mpi.img -- mm-install mpi4py openmpi=4.1 -y
```

> [!IMPORTANT]
> The OpenMPI version inside the container **must match the major and minor version** on the host.
> If the cluster has `openmpi/4.1.5`, install `openmpi=4.1`.

## Project Layout

```
run-mpi/                         ← run all commands from here
├── tasks.txt                    ← 8 tasks to distribute across MPI ranks
├── src/
│   ├── mpi_scatter.py           ← MPI scatter/gather Python script
│   ├── slurm/
│   │   ├── mpi_ntasks_only.sh   ← free-distribution: --ntasks=8 --mem-per-cpu
│   │   ├── mpi_tasks_per_node.sh← fixed geometry: --nodes=2 --ntasks-per-node=4
│   │   ├── mpi_hybrid.sh        ← hybrid: --ntasks-per-node=4 --cpus-per-task=2
│   │   └── mpi_manual.sh        ← passthrough workaround (manual host MPI launch)
│   ├── pbs/
│   │   ├── mpi_tasks_per_node.sh← select=2:ncpus=4:mpiprocs=4
|   |   ├── mpi_multichunk.sh    ← multi-chunk select=2:ncpus=3:mpiprocs=3+1:ncpus=2:mpiprocs=2
│   │   └── mpi_hybrid.sh        ← select=2:ncpus=8:mpiprocs=4:ompthreads=2
│   └── lsf/
│       ├── mpi_ntasks_only.sh   ← -n 8 (no span[], free distribution)
│       ├── mpi_tasks_per_node.sh← -n 8 -R "span[ptile=4]"
│       └── mpi_hybrid.sh        ← -n 8 -R "span[ptile=4] affinity[cores(2)]"
├── logs/                        ← scheduler output logs (created by scripts)
└── results/                     ← written by mpi_scatter.py after job completes
```

## Job Types

### MPI: Free Distribution (`ntasks_only`)

Tasks are placed freely across available nodes. Use `--mem-per-cpu` (SLURM) because
`--mem` requires `--nodes` to be unambiguous.

```bash
ml openmpi/4.1
condatainer run --dry-run src/slurm/mpi_ntasks_only.sh
condatainer run --debug src/slurm/mpi_ntasks_only.sh
```

> [!NOTE]
> PBS has no free-distribution equivalent. PBS `select` always requires per-chunk geometry.
> Use `src/pbs/mpi_tasks_per_node.sh` with `select=1` to run all tasks on a single node.

### MPI: Fixed Geometry (`tasks_per_node`)

Explicitly pins tasks per node, so both `NNODES` and `NTASKS_PER_NODE` are known.
`--mem` is valid here because `--nodes` is specified.

```bash
condatainer run --dry-run src/slurm/mpi_tasks_per_node.sh
condatainer run --debug src/slurm/mpi_tasks_per_node.sh
```

### Hybrid MPI+OpenMP (`hybrid`)

Each MPI rank spawns multiple OpenMP threads. CondaTainer automatically sets
`OMP_NUM_THREADS` to CPUs per task when generating the job script.

```bash
condatainer run --dry-run src/slurm/mpi_hybrid.sh
condatainer run --debug src/slurm/mpi_hybrid.sh
```

Replace `slurm/` with `pbs/` or `lsf/` for the equivalent job on those schedulers.

## How MPI Auto-Detection Works

When CondaTainer detects `ntasks > 1`, it **automatically** wraps submission with
`mpiexec -n <ntasks> condatainer run`. Each MPI rank launches its own container instance; they
communicate via the host MPI's process management interface.

```bash
# Preview the generated scheduler script
condatainer run --dry-run src/slurm/mpi_tasks_per_node.sh

# Submit (--debug keeps the generated scheduler script for inspection)
condatainer run --debug src/slurm/mpi_tasks_per_node.sh
```

Expected output (hostname and rank order may vary):

```
[node01 rank 0] processed: Analyze dataset Alpha
[node01 rank 0] processed: Analyze dataset Bravo
[node01 rank 1] processed: Analyze dataset Charlie
[node01 rank 1] processed: Analyze dataset Delta
[node02 rank 2] processed: Analyze dataset Echo
[node02 rank 2] processed: Analyze dataset Foxtrot
[node02 rank 3] processed: Analyze dataset Golf
[node02 rank 3] processed: Analyze dataset Hotel
```

## Further Reading

- [Scheduler Q&A](https://condatainer.readthedocs.io/en/latest/qa/scheduler.html) — auto-detection, passthrough, and cross-scheduler translation
- [Workspace Overlays](https://condatainer.readthedocs.io/en/latest/user_guide/workspace_overlays.html) — writable Conda environments for interactive work
