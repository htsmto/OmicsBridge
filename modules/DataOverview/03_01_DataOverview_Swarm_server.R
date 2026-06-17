# =============================================================================
# DataOverview - Swarm / Strip Plot Server (Orchestrator)
# File: modules/DataOverview/03_01_DataOverview_Swarm_server.R
# Purpose: Entry point for the Swarm plot sub-module. Sources data and plot
#          sub-files and wires their reactive values together.
# Edit this file when: changing the overall data flow between data prep
#                      and plot rendering sub-modules.
# =============================================================================

dataoverview_swarm_Server <- function(input, output, session, Original_geneset_list, df_datasets) {

  source("modules/DataOverview/03_01_DataOverview_Swarm_data.R", local = TRUE)
  source("modules/DataOverview/03_01_DataOverview_Swarm_plot.R", local = TRUE)

  # --- [1] Data preparation ----------------------------------------------------
  data_vals <- swarm_data_server(input, output, session, Original_geneset_list, df_datasets)

  # --- [2] Plot rendering ------------------------------------------------------
  swarm_plot_server(
    input, output, session,
    df_datasets,
    data_vals$df_gene_expression_map,
    data_vals$Ex_table_ready
  )
}
