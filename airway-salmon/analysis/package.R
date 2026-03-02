if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")

# 01_qc.qmd
pak::pak(c(
  "jsonlite",
  "tidyverse",
  "fastqcr"
))

# 02_deseq2.qmd
pak::pak(c(
  "DESeq2",
  "ggrepel",
  "org.Hs.eg.db"
))
