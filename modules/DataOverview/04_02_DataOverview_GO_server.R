# =============================================================================
# DataOverview - GO / Pathway Enrichment Server (Orchestrator)
# File: modules/DataOverview/04_02_DataOverview_GO_server.R
# Purpose: Entry point for the GO enrichment sub-module. Sources three sub-files
#          (calculation, plot, table) and wires their reactive values together.
# Edit this file when: changing the overall data flow between GO calculation
#                      and plot/table rendering sub-modules.
# =============================================================================

dataoverview_go_Server <- function(input, output, session, filtered_ex, selected_ex) {

  source("modules/DataOverview/04_02_DataOverview_GO_calc.R",  local = TRUE)
  source("modules/DataOverview/04_02_DataOverview_GO_plot.R",  local = TRUE)
  source("modules/DataOverview/04_02_DataOverview_GO_table.R", local = TRUE)

  # --- [1] GO enrichment calculation -------------------------------------------
  calc_vals <- go_calc_server(input, output, session, filtered_ex, selected_ex)

  # --- [2] Dot/bar chart rendering ---------------------------------------------
  go_plot_server(input, output, session, calc_vals$goResult, calc_vals$isCalculating)

  # --- [3] Result table and download -------------------------------------------
  go_table_server(input, output, session, calc_vals$goResult, calc_vals$isCalculating)
}
