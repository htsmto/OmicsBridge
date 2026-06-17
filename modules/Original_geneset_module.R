# =============================================================================
# Original Geneset Module Wrapper
# File: modules/Original_geneset_module.R
# Purpose: UI and Server entry points for the "Custom Gene Sets" tab, which
#          lets users view the built-in gene set library and upload their own
#          custom gene set files.
#
# Edit this file when:
#   - Adding a new gene set management sub-panel
#   - Changing which library this tab requires (libraries_OriginalDataset.R)
# =============================================================================

# --- [1] Library + UI source -------------------------------------------------
# The library and UI are sourced at app startup because this module is
# always initialised (not lazy-loaded) — gene sets may be needed by other tabs.
source("libraries/libraries_OriginalDataset.R")
source("modules/OriginalDataset/00_OriginalDataset_ui.R")


# --- [2] UI entry point -------------------------------------------------------
originalgenesetModuleUI <- function(id) {
  ns <- NS(id)
  original_geneset_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called immediately at app startup from app.R.
originalgenesetModuleServer <- function(id) {

  # --- [3-1] Source server files -------------------------------------------
  source("modules/OriginalDataset/01_OriginalDataset_TableView_server.R", local = TRUE)
  source("modules/OriginalDataset/02_OriginalDataset_Upload_server.R",    local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-2] Sub-module servers -------------------------------------------
    original_geneset_tableview_server(input, output, session)
    original_geneset_upload_server(input, output, session)
  })
}
