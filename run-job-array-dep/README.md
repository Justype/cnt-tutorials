# CondaTainer Array Jobs and Dependencies Tutorial

A minimal project about script arguments, array jobs, and job chaining in `condatainer run`. It demonstrates:

- Passing script arguments
- Array jobs (one subjob per sample)
- Job chaining with `--afterok`, `--afternotok`, and `--afterany` (HTCondor is not supported)

## Prerequisites

[CondaTainer](https://github.com/Justype/condatainer) installed with a supported scheduler.

> [!NOTE]
> `--array` and `--afterok` / `--afternotok` / `--afterany` require a scheduler. They are not supported in local mode.

## Relevant Flags

```
condatainer run [flags] <script> [script_args...]

Flags:
    --afterok string      Run after jobs succeed (colon-separated IDs, e.g. 123:456:789)
    --afternotok string   Run after jobs fail (colon-separated IDs)
    --afterany string     Run after jobs finish regardless of outcome (colon-separated IDs)
    --array string        Input file for array job (one entry per line)
    --array-limit int     Max concurrent array subjobs (0 = unlimited)
    --dry-run             Print the generated scheduler script without submitting

Global Flags:
    --debug   Enable debug mode with verbose output
```

## Project Layout

```
run-array-dep/              ← run all commands from here
├── src/
│   ├── samples.txt         ← sample list for array jobs (one sample per line)
│   ├── run_arg.sh          ← echoes its arguments; demonstrates $1, $2, NCPUS
│   ├── run_array.sh        ← array job: processes one sample per subjob
│   ├── run_ok.sh           ← short job that completes successfully (exit 0)
│   ├── run_notok.sh        ← short job that fails (exit 1)
│   ├── run_afterok.sh
│   ├── run_afternotok.sh
│   └── run_afterany.sh
├── logs/                   ← scheduler output logs (created by scripts)
└── results/                ← per-sample output (created by run_array.sh)
```

## Step 1 — Script Arguments

Pass arguments after the script name. They become `$1`, `$2`, … inside the script:

```bash
condatainer run --debug src/run_arg.sh hello 42 'spaced arg'
# Inside run_arg.sh: $1=hello  $2=42  $3=spaced arg
```

> [!IMPORTANT]
> All `condatainer` flags (`--dry-run`, `-c`, `-m`, etc.) must appear **before** the script name.
> Everything after the script name is forwarded to the script as positional arguments.
>
> ```bash
> condatainer run -c 4 src/run_arg.sh hello   # correct: -c sets NCPUS
> condatainer run src/run_arg.sh -c 4 hello   # WRONG: -c becomes $1 inside the script
> ```

## Step 2 — Array Jobs

Array jobs run the same script once per line of a file. Each non-empty line becomes one
scheduler subjob; its space-separated tokens map to `$1`, `$2`, … inside the script.

**`src/samples.txt`:**

```
sampleA Apple
sampleB Banana
sampleC Cherry
```

Preview first with `--dry-run`, then submit with an optional concurrency limit:

```bash
condatainer run --dry-run --array src/samples.txt src/run_array.sh
condatainer run --debug --array src/samples.txt --array-limit 2 src/run_array.sh
# subjob 1: $1=sampleA  $2=Apple
# subjob 2: $1=sampleB  $2=Banana
# subjob 3: $1=sampleC  $2=Cherry
```

Extra CLI args appear **after** the array-line tokens:

```bash
condatainer run --debug --array src/samples.txt src/run_array.sh v2
# subjob 1: $1=sampleA  $2=Apple   $3=v2
# subjob 2: $1=sampleB  $2=Banana  $3=v2
# subjob 3: $1=sampleC  $2=Cherry  $3=v2
```

The array job log path is determined by:

- same directory as the `--output` log
- job name (default: script name without extension)

Final output path: `<jobname>_<datetime>_<arrayid>_<merged_args>.log`

The default stdout and stderr are always redirected to `/dev/null`.

## Step 3 — Job Chaining

All `[CNT]` status messages go to **stderr**; only the job ID is printed to **stdout**. This lets
you capture the job ID with `$()` and pass it to a dependency flag:

```bash
JOB=$(condatainer run src/run_ok.sh)
```

Three flags control when a downstream job is allowed to start:

| Flag            | Downstream runs when upstream… |
|-----------------|--------------------------------|
| `--afterok`     | exited 0 (success)             |
| `--afternotok`  | exited non-zero (failure)      |
| `--afterany`    | finished (any outcome)         |

**`--afterok`** — run only after success:

```bash
JOB=$(condatainer run src/run_ok.sh)
condatainer run --afterok "$JOB" src/run_afterok.sh
```

**`--afternotok`** — run only after failure:

```bash
JOB=$(condatainer run src/run_ok.sh)
condatainer run --afternotok "$JOB" src/run_afternotok.sh # will NOT run
```

For `Slurm`, run `seff <jobid>` to see the failure reason. (`CANCELLED` because of dependency failure)

```bash
JOB=$(condatainer run src/run_notok.sh)
condatainer run --afternotok "$JOB" src/run_afternotok.sh
```

**`--afterany`** — run after any outcome:

```bash
JOB=$(condatainer run src/run_notok.sh)   # or run_ok.sh, it doesn't matter
condatainer run --afterany "$JOB" src/run_afterany.sh
```

Pass multiple upstream job IDs as a colon-separated list:

```bash
condatainer run --afterok "123:456:789" src/run_afterok.sh
```

Combine array jobs and chaining:

```bash
PROCESS=$(condatainer run --array src/samples.txt --array-limit 1 src/run_array.sh)
condatainer run --afterok "$PROCESS" src/run_afterok.sh
```

`run_afterok.sh` waits until **every** array subjob of `run_array.sh` succeeds.

> HTCondor has its own `DAGMan` system for job dependencies, which is different from other schedulers. Please use it directly for complex workflows.

## Further Reading

- [Using `condatainer run`](https://condatainer.readthedocs.io/en/latest/tutorials/run_upstream.html) — full `run` documentation with a real RNA-seq example
- [Module Overlays](https://condatainer.readthedocs.io/en/latest/user_guide/module_overlays.html) — installing tools and reference data as overlays
