# =============================================================================
# DataOverview - Correlation Analysis Server (Orchestrator)
# File: modules/DataOverview/03_02_DataOverview_Correlation_server.R
# Purpose: Entry point for the Correlation sub-module. Sources calc and plot
#          sub-files and wires their reactive values together.
# Edit this file when: changing the overall data flow between calculation
#                      and plot rendering sub-modules.
# =============================================================================

dataoverview_correlation_Server <- function(input, output, session, df_ex, Custom_geneset) {

  source("modules/DataOverview/03_02_DataOverview_Correlation_calc.R", local = TRUE)
  source("modules/DataOverview/03_02_DataOverview_Correlation_plot.R", local = TRUE)

  # --- [1] Correlation matrix calculation --------------------------------------
  calc_vals <- correlation_calc_server(input, output, session, df_ex, Custom_geneset)

  # --- [2] Heatmap and scatter plot rendering -----------------------------------
  correlation_plot_server(
    input, output, session,
    df_ex,
    calc_vals$Correlation_result_list,
    calc_vals$df_ex_for_correlation,
    calc_vals$isCalculating
  )
}
