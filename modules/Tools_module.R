# =============================================================================
# Tools Module Wrapper
# File: modules/Tools_module.R
# Purpose: UI and Server entry points for the Tools tab, which provides
#          utility functions: human/mouse gene ID conversion, symbol↔Ensembl
#          mapping, chromosomal locus finder, cross-tabular analysis,
#          Venn diagrams, and network plots.
#
# Edit this file when:
#   - Adding a new utility tool sub-panel
#   - Changing the reference data files (biomart table, gene coordinate table)
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
# 00_Tools_ui.R internally sources all sub-panel UI files (01 through 06).
source("modules/Tools/00_Tools_ui.R")


# --- [2] UI entry point -------------------------------------------------------
toolsModuleUI <- function(id) {
  ns <- NS(id)
  tools_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called by app.R the first time the user opens the Tools tab.
toolsModuleServer <- function(id) {

  # --- [3-1] Source server files (deferred) ----------------------------------
  source("modules/Tools/01_Tools_HumanMouse_server.R",   local = TRUE)
  source("modules/Tools/02_Tools_SymbolEns_server.R",    local = TRUE)
  source("modules/Tools/03_Tools_FindLoci_server.R",     local = TRUE)
  source("modules/Tools/04_Tools_CrossTabular_server.R", local = TRUE)
  source("modules/Tools/05_Tools_VennDiagram_server.R",  local = TRUE)
  source("modules/Tools/06_Tools_NetworkPlot_server.R",  local = TRUE)

  # --- [3-2] Reference data (deferred until tab is visited) -----------------
  # These TSV files are only needed for the Tools tab. Loading them here
  # avoids reading them at app startup.
  human_mouse_biomart_data <- tryCatch(
    read.table("data/biomart_comparison_chart.tsv", sep = "\t", header = TRUE, check.names = FALSE),
    error = function(e) {
      showNotification(paste("Could not load biomart_comparison_chart.tsv:", conditionMessage(e)),
                       type = "error", duration = 15)
      data.frame()
    }
  )
  Gene_coords_GRch38 <- tryCatch(
    read.table("data/Gene_coords_GRch38.tsv", sep = "\t", header = TRUE, check.names = FALSE),
    error = function(e) {
      showNotification(paste("Could not load Gene_coords_GRch38.tsv:", conditionMessage(e)),
                       type = "error", duration = 15)
      data.frame()
    }
  )

  moduleServer(id, function(input, output, session) {

    # --- [3-3] Sub-module servers -------------------------------------------
    tools_humanmouse_Server(input, output, session)
    tools_symbolens_Server(input, output, session)
    tools_findloci_Server_func1(input, output, session)
    tools_findloci_Server_func2(input, output, session)
    tools_crosstabular_Server(input, output, session)
    tools_venndiagram_Server(input, output, session)
    tools_networkplot_Server(input, output, session)
  })
}
