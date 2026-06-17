# =============================================================================
# OmicsBridge - Package Installation Script
# File: install_packages.R
# Purpose: Install all R packages required to run OmicsBridge on R 4.6.
#          Run once after upgrading R or on a fresh machine.
#
# Usage:
#   From terminal : Rscript install_packages.R
#   From RStudio  : source("install_packages.R")
#
# Estimated time: 20-60 minutes depending on network speed and whether
#   BSgenome reference packages are included (several GB each).
#
# Bioconductor version: 3.21 (matches R 4.6)
# =============================================================================


# --- [1] Bootstrap: BiocManager & remotes ------------------------------------
# BiocManager is required to install Bioconductor packages.
# remotes is required to install packages directly from GitHub.
# Both are installed from CRAN if not already present.

cat("=== [1/5] Installing BiocManager and remotes ===\n")

# Set CRAN mirror explicitly so the script works in non-interactive (Rscript) mode
options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Lock the Bioconductor release to the version that supports R 4.6.
# BiocManager will auto-detect the correct version if this is omitted,
# but specifying it explicitly prevents accidental upgrades.
BiocManager::install(version = "3.23", ask = FALSE, update = FALSE)

if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes")


# --- [2] CRAN packages -------------------------------------------------------
# These packages are available on CRAN and installed via install.packages().
# Grouped by functional area for readability.

cat("=== [2/5] Installing CRAN packages ===\n")

cran_pkgs <- c(
  # --- Shiny UI framework ---
  # Core packages for building and styling the dashboard interface.
  "shiny",            # Web application framework
  "shinyjs",          # JavaScript operations from R (enable/disable inputs, etc.)
  "shinydashboard",   # AdminLTE-based dashboard layout
  "shinyWidgets",     # Extended input widgets (materialSwitch, pickerInput, etc.)
  "shinycssloaders",  # Spinner overlays while outputs load

  # --- Data display ---
  "DT",               # Interactive DataTable (wraps DataTables.js)

  # --- Data wrangling ---
  "dplyr",            # Data manipulation verbs (filter, mutate, select, etc.)
  "tidyr",            # Data reshaping (pivot_wider, pivot_longer, etc.)
  "reshape2",         # Legacy melt/dcast used in clinical correlation plots

  # --- General plotting ---
  "ggplot2",          # Core plotting library (used throughout)
  "ggbeeswarm",       # Beeswarm / jitter strip plots (Swarm tab)
  "patchwork",        # Combine multiple ggplots into one figure
  "ggrepel",          # Non-overlapping text/label repel annotations
  "ggraph",           # Network / graph layouts built on ggplot2
  "eulerr",           # Euler / Venn diagrams (Tools tab)
  "visNetwork",       # Interactive network visualisation (Tools tab)
  "igraph",           # Graph/network computation (Tools tab)
  "circlize",         # Circular plots; also used by EnrichedHeatmap
  "cowplot",          # Plot composition helpers (used in scRNA panels)
  "colourpicker",     # Inline colour picker widget (Epigenome UI)

  # --- Survival analysis ---
  "survival",         # Core survival objects (Surv, survfit, coxph)
  "survminer",        # KM curve visualisation (ggsurvplot)

  # --- scRNA-seq helpers (non-Bioconductor) ---
  "Rtsne",            # t-SNE dimensionality reduction
  "umap"              # UMAP dimensionality reduction
)

install.packages(cran_pkgs)


# --- [3] Bioconductor packages -----------------------------------------------
# Installed via BiocManager which handles version compatibility automatically.
# The BSgenome packages are large (several GB each); comment them out if you
# do not need the Epigenome / motif-scan features.

cat("=== [3/5] Installing Bioconductor packages ===\n")

bioc_pkgs <- c(
  # --- Gene set enrichment ---
  # Used in DataOverview (GO, GSEA) and Clinical (Signature, GSVA).
  "GSEABase",         # Gene Set classes and GMT file parsing (getGmt)
  "clusterProfiler",  # ORA and GSEA enrichment analysis
  "org.Hs.eg.db",     # Human gene ID mapping database
  "org.Mm.eg.db",     # Mouse gene ID mapping database
  "fgsea",            # Fast pre-ranked GSEA
  "GSVA",             # Gene Set Variation Analysis (ssGSEA, GSVA scoring)

  # --- Genomics (Tools and Epigenome) ---
  "GenomicRanges",    # GRanges objects for interval arithmetic
  "GenomicFeatures",  # TxDb objects; used in ChIPseeker
  "ChIPseeker",       # ChIP-seq peak annotation (Tools tab)
  "AnnotationDbi",    # Annotation database interface (used by clusterProfiler)
  "rtracklayer",      # Import/export genomic data (BigWig, BED, etc.)

  # --- Visualisation (Epigenome) ---
  "EnrichedHeatmap",  # Heatmap of signal over genomic regions
  "Gviz",             # Genome-wide track visualisation (bigWig / BAM)
  "igvShiny",         # Embedded IGV browser Shiny widget

  # --- Genome reference sequences (Epigenome motif scan) ---
  # These are large downloads (~3 GB each). Comment out if not using Epigenome.
  "BSgenome.Hsapiens.UCSC.hg38",  # Human hg38 reference sequences
  "BSgenome.Hsapiens.UCSC.hg19",  # Human hg19 reference sequences

  # --- Motif scanning (Epigenome) ---
  "PWMEnrich",                    # Position weight matrix enrichment
  "PWMEnrich.Hsapiens.background", # Pre-computed human background models

  # --- scRNA-seq (Seurat ecosystem) ---
  # Seurat 5 is on CRAN but installing via BiocManager ensures all
  # Bioconductor dependencies (SingleCellExperiment, etc.) are resolved.
  "AUCell",           # Gene set activity scoring per cell (AUC method)
  "Seurat"            # Single-cell RNA-seq analysis framework
)

BiocManager::install(bioc_pkgs, ask = FALSE, update = FALSE)


# --- [4] GitHub-only packages ------------------------------------------------
# These packages are not on CRAN or Bioconductor and must be installed
# directly from GitHub. Requires an internet connection.
#
# Tip: If you hit rate limits, set a GitHub PAT first:
#   usethis::create_github_token()  # opens browser to create a token
#   gitcreds::gitcreds_set()        # stores the token in the system keyring

cat("=== [4/5] Installing GitHub packages ===\n")

# MCPcounter: cell-type deconvolution method (Clinical > Deconvolution tab)
# Repository: https://github.com/ebecht/MCPcounter
# Wrapped in tryCatch so a 404 / network issue does not abort the whole script.
tryCatch(
  remotes::install_github(
    "ebecht/MCPcounter",
    ref          = "master",
    subdir       = "Source",   # package code lives in the Source/ subdirectory
    dependencies = TRUE,
    upgrade      = "never"
  ),
  error = function(e) {
    cat("[!] MCPcounter install failed:", conditionMessage(e), "\n")
    cat("    Try manually: remotes::install_github('ebecht/MCPcounter', ref='master')\n")
  }
)

# xCell: multi-cell-type enrichment deconvolution (Clinical > Deconvolution tab)
# Repository: https://github.com/dviraran/xCell
tryCatch(
  remotes::install_github(
    "dviraran/xCell",
    dependencies = TRUE,
    upgrade      = "never"
  ),
  error = function(e) {
    cat("[!] xCell install failed:", conditionMessage(e), "\n")
    cat("    Try manually: remotes::install_github('dviraran/xCell')\n")
  }
)


# --- [5] Verification --------------------------------------------------------
# Check that every package was installed successfully.
# Packages that failed to install will show NA in the Version column.

cat("=== [5/5] Verifying installation ===\n")

all_pkgs <- c(cran_pkgs, bioc_pkgs, "MCPcounter", "xCell")

versions <- sapply(all_pkgs, function(pkg) {
  tryCatch(
    as.character(packageVersion(pkg)),
    error = function(e) NA_character_
  )
})

result_df <- data.frame(
  Package = names(versions),
  Version = unname(versions),
  Status  = ifelse(is.na(versions), "FAILED", "OK"),
  row.names = NULL
)

cat("\n=== Installation Summary ===\n")
print(result_df, row.names = FALSE)

failed_pkgs <- result_df$Package[result_df$Status == "FAILED"]

if (length(failed_pkgs) > 0) {
  cat(
    "\n[!] The following packages failed to install:\n",
    paste(" -", failed_pkgs, collapse = "\n"), "\n",
    "\nPlease check error messages above and re-run the relevant section.\n"
  )
} else {
  cat("\n[OK] All", nrow(result_df), "packages installed successfully.\n")
  cat("You can now launch OmicsBridge with: shiny::runApp()\n")
}
