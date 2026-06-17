# =============================================================================
# IntegrateTwoDataset Module Wrapper
# File: modules/IntegrateTwoDataset_module.R
# Purpose: UI and Server entry points for the "Integrate two datasets" tab,
#          which shows two datasets side-by-side and produces integrated
#          scatter / correlation plots.
#
# Edit this file when:
#   - Adding a new integration visualisation sub-panel
#   - Adding library dependencies specific to this tab
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_IntegrateTwoDataset_ui.R sources the two sub-panel UI files (01, 02).
source("modules/IntegrateTwoDataset/00_IntegrateTwoDataset_ui.R")


# --- [2] UI entry point -------------------------------------------------------
IntegrateTwoDatasetModuleUI <- function(id) {
  ns <- NS(id)
  IntegrateTwoDataset_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R the first time the user opens the Integrate_two_dataset tab
# (lazy-loaded; not called at startup).
IntegrateTwoDatasetModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred) ----------------------------------
  source("modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_server.R",    local = TRUE)
  source("modules/IntegrateTwoDataset/02_IntegrateTwoDataset_IntegrationPlot_server.R", local = TRUE)

  # --- [3-2] Shared constants -----------------------------------------------
  colour_pallets <- c("viridis", "magma", "plasma", "inferno", "cividis")

  moduleServer(id, function(input, output, session) {

    # --- [3-3] Sub-module servers -------------------------------------------
    # SideBySide returns a combined reactive data object used by IntegrationPlot.
    data1_plus_data2 <- IntegrateTwoDataset_SideBySide_server(input, output, session)
    IntegrateTwoDataset_IntegrationPlot_server(input, output, session, data1_plus_data2)
  })
}
