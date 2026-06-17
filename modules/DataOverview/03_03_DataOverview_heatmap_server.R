# =============================================================================
# DataOverview - Heatmap Server (Orchestrator)
# File: modules/DataOverview/03_03_DataOverview_heatmap_server.R
# Purpose: Entry point for the Heatmap sub-module. Sources three sub-files
#          (data prep, clustering, rendering) and wires their reactive values.
# Edit this file when: changing the overall data flow between data prep,
#                      clustering, and heatmap rendering sub-modules.
# =============================================================================

dataoverview_heatmap_Server <- function(input, output, session, df_ex, Custom_geneset) {

  source("modules/DataOverview/03_03_DataOverview_heatmap_data.R",       local = TRUE)
  source("modules/DataOverview/03_03_DataOverview_heatmap_clustering.R", local = TRUE)
  source("modules/DataOverview/03_03_DataOverview_heatmap_plot.R",       local = TRUE)

  # --- [1] Data preparation (gene filtering, matrix construction) --------------
  data_vals <- heatmap_data_server(input, output, session, df_ex, Custom_geneset)

  # --- [2] Clustering settings and annotation ----------------------------------
  cluster_vals <- heatmap_clustering_server(
    input, output, session,
    data_vals$ex_datafreme_for_heatmap,
    data_vals$Input_genes_used,
    data_vals$Data_Overview_heatmap_status
  )

  # --- [3] ComplexHeatmap rendering and download --------------------------------
  heatmap_plot_server(
    input, output, session,
    data_vals$ex_datafreme_for_heatmap,
    cluster_vals$clustered_heatmap_ex
  )
}
