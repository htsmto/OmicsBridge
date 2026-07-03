# =============================================================================
# Clinical Module Wrapper
# File: modules/Clinical_module.R
# Purpose: Defines UI and Server entry points for the Clinical Data Analysis
#          tab. Sources UI files at startup, defers all server source() calls
#          until the user first navigates to this tab.
#
# Edit this file when:
#   - Adding or removing a clinical analysis sub-panel
#   - Changing the order sub-module servers are initialised
#   - Adjusting shared data (gene set file path, etc.)
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_Clinical_ui.R internally sources all sub-panel UI files (01 through 11).
source("modules/Clinical/00_Clinical_ui.R")

# Colour palette choices shared across multiple UI dropdowns.
# Must be defined at top level (before UI functions run) so UI files can use it.
colour_pallets <- c("viridis", "magma", "plasma", "inferno", "cividis")


# --- [2] UI entry point -------------------------------------------------------
clinicalModuleUI <- function(id) {
  ns <- NS(id)
  Clinical_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Invoked by app.R the first time the user opens the Clinical_dataset tab.
# Server files are sourced here (deferred) to avoid loading heavy packages at
# app startup.
clinicalModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred) ----------------------------------
  source("modules/Clinical/01_clinical_DataSelection_server.R",  local = TRUE)
  source("modules/Clinical/02_clinical_ViewData_server.R",        local = TRUE)
  source("modules/Clinical/03_clinical_Survival_server.R",        local = TRUE)
  source("modules/Clinical/04_clinical_GeneCorrelation_server.R", local = TRUE)
  source("modules/Clinical/05_clinical_Mutation_server.R",        local = TRUE)
  source("modules/Clinical/06_clinical_ExpressionCompare_server.R", local = TRUE)
  source("modules/Clinical/07_clinical_Signature_server.R",       local = TRUE)
  source("modules/Clinical/08_clinical_Deconvolution_server.R",   local = TRUE)
  source("modules/Clinical/09_clinical_CompareCohorts_server.R",  local = TRUE)
  source("modules/Clinical/10_clinical_COSMIC_server.R",          local = TRUE)
  source("modules/Clinical/11_clinical_upload_server.R",          local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-3] Shared data ---------------------------------------------------
    # Custom gene sets used across survival, signature, deconvolution, etc.
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

    # --- [3-4] Sub-module servers --------------------------------------------
    # DataSelection returns file paths; ViewData loads the actual data tables.
    # All downstream modules receive the loaded data as reactive arguments.
    data_path_list  <- clinical_DataSelection_server(input, output, session)
    loaded_data_table <- clinical_ViewData_server(
      input, output, session,
      data_path_list$Name,
      data_path_list$Ex_path,
      data_path_list$Surv_path,
      data_path_list$Meta_path,
      data_path_list$Mut_path
    )
    clinical_Survival_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Survival,
      loaded_data_table$Meta_data,
      Custom_genesets)
    clinical_GeneCorrelation_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Meta_data,
      Custom_genesets)
    clinical_Mutation_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Survival,
      loaded_data_table$Meta_data,
      loaded_data_table$Mutation,
      Custom_genesets)
    clinical_ExpressionCompare_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Meta_data,
      Custom_genesets)
    clinical_Signature_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Survival,
      loaded_data_table$Meta_data,
      Custom_genesets)
    clinical_Deconvolution_server(input, output, session,
      loaded_data_table$Gene_expression,
      loaded_data_table$Survival,
      loaded_data_table$Meta_data,
      Custom_genesets)
    clinical_CompareCohorts_server(input, output, session,
      data_path_list$Clinical_dataset,
      Custom_genesets)
    clinical_COSMIC_server(input, output, session, Custom_genesets)
    clinical_upload_server(input, output, session)
  })
}
