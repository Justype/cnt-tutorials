args <- commandArgs(trailingOnly = TRUE)
samples_file <- if (length(args) >= 1) args[1] else stop("Usage: Rscript collect.R [samples.txt]")

suppressPackageStartupMessages(library(tximport))

srr <- read.table(samples_file, header = FALSE)[[1]]

files <- file.path("data/quants", srr, "quant.sf")
names(files) <- srr

missing <- files[!file.exists(files)]
if (length(missing) > 0) {
    stop("Missing quant.sf files:\n  ", paste(missing, collapse = "\n  "))
}

# Build tx2gene from GENCODE GTF (set by */gtf-gencode/* overlay)
gtf_file <- Sys.getenv("ANNOTATION_GTF")
if (gtf_file == "") stop("ANNOTATION_GTF not set — ensure */gtf-gencode/* overlay is loaded.")
if (!file.exists(gtf_file)) stop("ANNOTATION_GTF not found: ", gtf_file)

message("Building tx2gene from: ", gtf_file)
cat_cmd <- if (grepl("\\.gz$", gtf_file)) "zcat" else "cat"
tx_lines <- readLines(pipe(paste(cat_cmd, shQuote(gtf_file), "| awk -F'\\t' '$3==\"transcript\"'")))

extract_attr <- function(attrs, key) {
    m <- regmatches(attrs, regexpr(paste0(key, ' "[^"]*"'), attrs))
    sub(paste0(key, ' "([^"]*)"'), "\\1", m)
}

tx2gene <- data.frame(
    tx_id   = extract_attr(tx_lines, "transcript_id"),
    gene_id = extract_attr(tx_lines, "gene_id")
)
message(sprintf("tx2gene: %d transcripts -> %d genes", nrow(tx2gene), length(unique(tx2gene$gene_id))))

txi_gene <- tximport(files, type = "salmon", tx2gene = tx2gene, dropInfReps = TRUE)

dir.create("results", showWarnings = FALSE)
saveRDS(txi_gene, "results/txi_gene.rds")

message(sprintf(
    "Written: results/txi_gene.rds (%d genes x %d samples)",
    nrow(txi_gene$counts), ncol(txi_gene$counts)
))
