# =============================================================================
# scRNA Module Wrapper
# File: modules/scRNA_module.R
# Purpose: UI and Server entry points for the scRNA-seq analysis tab.
#          Seurat is loaded in app.R before this module's server is called,
#          so it is available when the server files are sourced here.
#
# Edit this file when:
#   - Adding a new scRNA visualisation sub-panel (e.g., trajectory, pseudotime)
#   - Changing the order in which feature-plot sub-servers are initialised
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_scRNA_ui.R sources all sub-panel UI files internally.
source("modules/scRNA/00_scRNA_ui.R")


# --- [2] UI entry point -------------------------------------------------------
scRNAModuleUI <- function(id) {
  ns <- NS(id)
  scRNA_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R after Seurat has been loaded (lazy, first tab visit only).
scRNAModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred) ----------------------------------
  # These files define server functions that depend on Seurat being available.
  source("modules/scRNA/01_scRNA_DataSelection_server.R",     local = TRUE)
  source("modules/scRNA/02_01_scRNA_UMAP_server.R",           local = TRUE)
  source("modules/scRNA/02_02_scRNA_Feature_server.R",        local = TRUE)
  source("modules/scRNA/02_02_01_scRNA_Feature_umap_server.R",   local = TRUE)
  source("modules/scRNA/02_02_02_scRNA_Feature_violin_server.R", local = TRUE)
  source("modules/scRNA/02_02_03_scRNA_Feature_dot_server.R",    local = TRUE)
  source("modules/scRNA/02_02_04_scRNA_Feature_pie_server.R",    local = TRUE)
  source("modules/scRNA/02_02_05_scRNA_Feature_AUC_server.R",    local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-2] Shared data ---------------------------------------------------
    # Dataset index and custom gene sets are loaded once and passed to servers.
    Dataset <- tryCatch(
      data.frame(read.delim("data/Database.tsv", sep = "\t", header = TRUE, check.names = FALSE)),
      error = function(e) {
        showNotification(paste("Could not load Database.tsv:", conditionMessage(e)),
                         type = "error", duration = 15)
        data.frame()
      }
    )
    Custom_genesets <- tryCatch(
      data.frame(read.delim("data/Genesets_list.tsv", sep = "\t", header = TRUE, check.names = FALSE)),
      error = function(e) {
        showNotification(paste("Could not load Genesets_list.tsv:", conditionMessage(e)),
                         type = "error", duration = 15)
        data.frame()
      }
    )

    # --- [3-3] Sub-module servers --------------------------------------------
    # UMAP server loads the Seurat object and returns it as a reactive.
    # All Feature sub-servers receive the same Seurat object and gene inputs.
    scRNA_DataSelection_server(input, output, session, Dataset)
    Seurat_object <- scRNA_UMAP_server(input, output, session, Dataset)
    inputs <- scRNA_Feature_server(input, output, session, Custom_genesets)
    scRNA_Feature_server_umap(  input, output, session, Seurat_object, inputs$flag, inputs$gene_list_mannual, inputs$gene_list_custom)
    scRNA_Feature_server_violin(input, output, session, Seurat_object, inputs$flag, inputs$gene_list_mannual, inputs$gene_list_custom)
    scRNA_Feature_server_dot(   input, output, session, Seurat_object, inputs$flag, inputs$gene_list_mannual, inputs$gene_list_custom)
    scRNA_Feature_server_pie(   input, output, session, Seurat_object, inputs$flag, inputs$gene_list_mannual, inputs$gene_list_custom)
    scRNA_Feature_server_AUC(   input, output, session, Seurat_object, inputs$flag, inputs$gene_list_mannual, inputs$gene_list_custom)
  })
}
