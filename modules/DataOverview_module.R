# =============================================================================
# DataOverview Module Wrapper
# File: modules/DataOverview_module.R
# Purpose: Defines the UI and Server entry points for the Transcriptome /
#          Data Overview tab. Sources UI files at definition time (needed for
#          Shiny to build the page layout), and defers all server-side source()
#          calls until the module is first initialised (lazy loading).
#
# Edit this file when:
#   - Adding or removing a sub-panel to the Data Overview tab
#   - Changing the order in which sub-module servers are called
#   - Adjusting shared data (e.g., colour palettes, geneset file path)
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_DataOverview_ui.R internally sources all sub-panel UI files via a chain:
#   00 → 01, 02 → (02 sources 03_*, 04_*)
# Only this single source() call is needed here at the top level.
source("modules/DataOverview/00_DataOverview_ui.R")

# Colour palette choices shared across multiple UI dropdowns.
# Must be defined at top level (before UI functions run) so UI files can use it.
colour_pallets <- c("viridis", "magma", "plasma", "inferno", "cividis")


# --- [2] UI entry point -------------------------------------------------------
# Called by body.R when assembling the tab layout. Must be available at app
# startup, which is why UI files are sourced above (outside the server function).
dataoverviewModuleUI <- function(id) {
  ns <- NS(id)
  DataOverview_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R the first time the user clicks the Data_Overview tab.
# All server-side source() calls live here so that the ~11 heavy server files
# are never read during app startup.
dataoverviewModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred until first tab visit) -----------
  # Each file defines one server function used in the moduleServer body below.
  source("modules/DataOverview/01_DataOverview_DataSelection_server.R", local = TRUE)
  source("modules/DataOverview/02_DataOverview_DataOverview_server.R",  local = TRUE)
  source("modules/DataOverview/03_01_DataOverview_Swarm_server.R",      local = TRUE)
  source("modules/DataOverview/03_02_DataOverview_Correlation_server.R",local = TRUE)
  source("modules/DataOverview/03_03_DataOverview_heatmap_server.R",    local = TRUE)
  source("modules/DataOverview/03_04_DataOverview_PCA_server.R",        local = TRUE)
  source("modules/DataOverview/04_01_DataOverview_MainPlot_server.R",   local = TRUE)
  source("modules/DataOverview/04_02_DataOverview_GO_server.R",         local = TRUE)
  source("modules/DataOverview/04_03_DataOverview_GESA_server.R",       local = TRUE)
  source("modules/DataOverview/04_04_DataOverview_TF_server.R",         local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-3] Shared data ---------------------------------------------------
    # Gene set list used by Swarm, Heatmap, Correlation, MainPlot, and GSEA.
    # Loaded once here and passed as an argument to each sub-server.
    Original_geneset_list <- tryCatch(
      data.frame(read.delim("data/Genesets_list.tsv", sep = "\t", header = TRUE)),
      error = function(e) {
        showNotification(paste("Could not load Genesets_list.tsv:", conditionMessage(e)),
                         type = "error", duration = 15)
        data.frame()
      }
    )

    # --- [3-4] Sub-module servers --------------------------------------------
    # Each call registers the reactive logic for one sub-panel.
    # Data flows downward: DataSelection → DataOverview → analysis panels.
    Dataset_dataclass <- dataoverview_dataselection_Server(input, output, session)
    show_Overview_server(input, output, session, Dataset_dataclass)
    df_ex <- dataoverview_dataoverview_Server(input, output, session)
    dataoverview_swarm_Server(input, output, session, Original_geneset_list, df_ex)
    dataoverview_pca_Server(input, output, session, df_ex)
    dataoverview_heatmap_Server(input, output, session, df_ex, Original_geneset_list)
    dataoverview_correlation_Server(input, output, session, df_ex, Original_geneset_list)
    df_main <- dataoverview_mainplot_Server(input, output, session, Original_geneset_list, df_ex)
    dataoverview_go_Server(input, output, session, df_main$df_outliers, df_main$Overview_selected_table)
    dataoverview_gsea_Server(input, output, session, df_ex, Original_geneset_list)
    dataoverview_TF_Server(input, output, session, df_ex)
  })
}
