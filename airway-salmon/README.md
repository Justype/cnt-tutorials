# Airway RNA-seq: fastp + Salmon

RNA-seq quantification pipeline using the [Airway dataset (GSE52778)](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778).

For simplicity, we only use 6 paired samples — 3 cell lines × 2 conditions (untreated / treated with dexamethasone).

**Pipeline:** SRA download → fastp trimming → Salmon quantification → gene-level tximport object ready for DESeq2/edgeR

## Prerequisites

[CondaTainer](https://github.com/Justype/condatainer) installed with a scheduler available.

Install required overlays (checks for existing ones, only installs missing):

```bash
bash src/setup.sh
```

## Project Layout

```
airway-salmon/             ← run all commands from here
├── metadata/
│   ├── samples.txt        ← SRR accessions + condition + cell_line
│   └── SraRunTable.csv    ← full SRA metadata
├── src/
|   ├── overlay/
│   │   ├── r-collect.yml  ← conda env definition
│   │   └── r-collect.sqf  ← built bundle overlay
│   ├── r/
│   │   └── collect.R      ← create tximport object (called by 03_collect.sh)
│   ├── 00_download.sh
│   ├── 01_trim.sh
│   ├── 02_quant.sh
│   ├── 03_collect.sh
│   └── setup.sh           ← check and install all required overlays
├── data/
│   ├── fastq/             ← raw FASTQ + FastQC reports (by 00_download.sh)
│   ├── fastq-trimmed/     ← trimmed FASTQ + fastp + FastQC reports (by 01_trim.sh)
│   └── quants/            ← per-sample Salmon output (by 02_quant.sh)
├── analysis/
│   ├── 01_qc.qmd          ← fastp trimming + Salmon mapping rate summary
│   └── 02_deseq2.qmd      ← PCA, volcano plot, DE results (dexamethasone vs untreated)
└── results/
    └── txi_gene.rds       ← tximport gene-level object (for DESeq2/edgeR)
```

## Quickstart

Run from the `airway-salmon/` directory:

```bash
DL=$(condatainer run --array metadata/samples.txt src/00_download.sh)
TRIM=$(condatainer run --array metadata/samples.txt --afterok "$DL" src/01_trim.sh)
QUANT=$(condatainer run --array metadata/samples.txt --afterok "$TRIM" src/02_quant.sh)
condatainer run --afterok "$QUANT" src/03_collect.sh metadata/samples.txt
```

On some clusters, the download speed of compute nodes may be slow. You can run the download step on login nodes.

```bash
# Run in tmux or screen session to avoid interruption
while read -r sample _ ; do
    condatainer run --local src/00_download.sh "$sample"
done < metadata/samples.txt
```

Once the FASTQ files are downloaded, you can run the following steps:

```bash
TRIM=$(condatainer run --array metadata/samples.txt src/01_trim.sh)
QUANT=$(condatainer run --array metadata/samples.txt --afterok "$TRIM" src/02_quant.sh)
condatainer run --afterok "$QUANT" src/03_collect.sh metadata/samples.txt
```

> [!TIP]
> You can use `--arraylimit 3` to limit the concurrent subjobs if your cluster has a small job limit.
>
> All the scripts (`sh` and `R`) only use the first column of the `metadata/samples.txt` file as input. You can modify the file to include more samples or different conditions, as long as the first column contains the SRR accessions.

## Inodes and Sizes

The used compression method is `zstd` level 8.

| Overlay | Inner Inodes | Inner Size | SquashFS Size |
| --- | --- | --- | --- |
| parallel-fastq-dump/0.6.7 | 12999 | 483M | 169M |
| fastp/1.1.0 | 72 | 27M | 9M |
| trim-galore/0.6.11 | 15566 | 732M | 278M |
| salmon/1.10.2 | 17711 | 264M | 57M |
| grch38/genome/gencode | 7 | 3G | 854M |
| grch38/transcript-gencode/47 | 7 | 632M | 115M |
| grch38/salmon/1.10.2/gencode47 | 21 | 17G | 14G |
| grch38/gtf-gencode/47 | 7 | 1.7G | 54M |
| ./src/overlay/r-collect.sqf | 14920 | 1.4G | 382M |

- Inodes saved: 61k
- Disk saved: 9G / 25G

> [!NOTE]
> Inodes include folder entries.
>
> zstd compression has higher compression ratio and faster decompression speed than gzip. See this [benchmark](https://github.com/inikep/lzbench).
>
> If you care about decompression speed, you can use lz4. It is the fastest but with lower compression ratio.

## Downstream Analysis

The `analysis/` folder contains two Quarto documents:

- `01_qc.qmd`: summary of trimming and mapping
- `02_deseq2.qmd`: PCA, volcano plot, and DE results (dexamethasone vs untreated)
- ... and you can add more!

For downstream, I recommend using writable workspace overlay (ext3 img) instead of read-only bundle overlay.

You can use the `condatainer helper` to launch an RStudio Server with the workspace overlay:

```bash
# Create a 20G sparse workspace overlay
condatainer o --sparse -s 20g src/overlay/env.img
# Update helper scripts
condatainer helper --update
# Launch RStudio Server with the workspace overlay
#   the env.img will be auto-detected and used in writable mode
condatainer helper rstudio-server -w -r 4.4
```

Then you can use the RStudio Server on the clusters, instead of downloading the data to your local machine for analysis.

> [!NOTE]
> Please choose a unique port when launching the RStudio Server, to avoid conflicts with other users.
>
> ```
> condatainer helper rstudio-server -w -r 4.4 -p 31021
> ```
