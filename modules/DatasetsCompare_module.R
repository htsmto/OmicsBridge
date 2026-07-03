# =============================================================================
# DatasetsCompare Module Wrapper
# File: modules/DatasetsCompare_module.R
# Purpose: UI and Server entry points for the "Compare across datasets" tab,
#          which lets users select multiple datasets, find gene overlap, and
#          compare expression of a single gene across cohorts.
#
# Edit this file when:
#   - Adding a new comparison sub-panel
#   - Changing the library dependencies for this tab (libraries_DatasetsCompare.R)
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_DatasetsCompare_ui.R sources the three sub-panel UI files (01, 02, 03).
source("modules/DatasetsCompare/00_DatasetsCompare_ui.R")


# --- [2] UI entry point -------------------------------------------------------
DatasetsCompareModuleUI <- function(id) {
  ns <- NS(id)
  DatasetsCompare_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R the first time the user opens the Compare_across_datasets tab
# (lazy-loaded; not called at startup).
DatasetsCompareModuleServer <- function(id) {

  # --- [3-1] Source library + server files (deferred) -----------------------
  # The library file is sourced here rather than at app startup to keep the
  # initial load fast.
  source("libraries/libraries_DatasetsCompare.R", local = TRUE)
  source("modules/DatasetsCompare/01_DatasetsCompare_DataSelection_server.R", local = TRUE)
  source("modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_server.R",    local = TRUE)
  source("modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_server.R",local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-2] Shared data ---------------------------------------------------
    Custom_genesets <- reactiveFileReader(3000, session, "data/Genesets_list.tsv", function(f) {
      tryCatch(
        data.frame(read.delim(f, sep = "\t", header = TRUE, check.names = FALSE)),
        error = function(e) {
          showNotification(paste("Could not load Genesets_list.tsv:", conditionMessage(e)),
                           type = "error", duration = 15)
          data.frame()
        }
      )
    })

    # --- [3-3] Sub-module servers -------------------------------------------
    # DataSelection returns the table of selected datasets, which is passed
    # to both GetOverlap and CompareOneGene.
    selected_datasets_table <- DatasetsCompare_DataSelection_server(input, output, session)
    DatasetsCompare_GetOverlap_server(input, output, session, selected_datasets_table)
    DatasetsCompare_CompareOneGene_server(input, output, session, selected_datasets_table, Custom_genesets)
  })
}
