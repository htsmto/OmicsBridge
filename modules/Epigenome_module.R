# =============================================================================
# Epigenome Module Wrapper
# File: modules/Epigenome_module.R
# Purpose: UI and Server entry points for the Epigenome Visualisation tab,
#          covering methylation profiles, genome-wide visualisation, IGV
#          browser integration, and motif scanning.
#
# Edit this file when:
#   - Adding a new epigenome analysis sub-panel
#   - Changing which libraries this tab requires (see libraries_Epigenome.R)
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_Epigenome_ui.R sources all sub-panel UI files.
source("modules/Epigenome/00_Epigenome_ui.R")


# --- [2] UI entry point -------------------------------------------------------
EpigenomeModuleUI <- function(id) {
  ns <- NS(id)
  Epigenome_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R the first time the user opens the igv tab.
# libraries_Epigenome.R is sourced in app.R before this function is called.
EpigenomeModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred) ----------------------------------
  source("modules/Epigenome/01_Epigenome_profile_server.R",                   local = TRUE)
  source("modules/Epigenome/02_Epigenome_genomevisualisation_server.R",      local = TRUE)
  source("modules/Epigenome/03_Epigenome_igv_server.R",                      local = TRUE)
  source("modules/Epigenome/04_Epigenome_findEnhancerPromoter_server.R",     local = TRUE)
  source("modules/Epigenome/05_Epigenome_motifScan_server.R",                local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-2] Shared data ---------------------------------------------------
    # Dataset index is wrapped in reactiveVal so downstream servers can depend
    # on it reactively (e.g., if the database is updated during the session).
    Dataset <- reactiveVal({
      tryCatch(
        data.frame(read.delim("data/Database.tsv", sep = "\t", header = TRUE, check.names = FALSE)),
        error = function(e) {
          showNotification(paste("Could not load Database.tsv:", conditionMessage(e)),
                           type = "error", duration = 15)
          data.frame()
        }
      )
    })

    # --- [3-3] Sub-module servers -------------------------------------------
    Epigenome_profile_server(input, output, session, Dataset)
    Epigenome_genomevisualisation_server(input, output, session, Dataset)
    Epigenome_igv_server(input, output, session, Dataset)
    epigenome_findEnhancerPromoter_server(input, output, session, Dataset)
    Epigenome_motifScan_server(input, output, session)
  })
}
