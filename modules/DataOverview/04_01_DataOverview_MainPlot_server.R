# =============================================================================
# DataOverview - MainPlot: Orchestrator
# File: modules/DataOverview/04_01_DataOverview_MainPlot_server.R
# Purpose: Entry point for the main scatter plot feature. Sources the four
#          sub-files below and wires their reactive outputs together:
#
#   axis.R        → renders X/Y axis dropdowns
#   gene_input.R  → validates manually entered gene lists (Input 1 & 2)
#   filter.R      → threshold / pathway / custom-geneset filtering
#   selection.R   → plot-brush selection (brushedPoints)
#   plot.R        → assembles and renders the ggplot2 scatter plot
#
# Edit this file when: changing the order or structure of the sub-modules,
#                       or adding a new sub-feature to the MainPlot.
# Edit a sub-file when: changing one specific aspect of the scatter plot.
# =============================================================================

dataoverview_mainplot_Server <- function(input, output, session, Original_geneset_list, df_ex, data_type) {

  # --- [1] Source sub-files --------------------------------------------------
  # Each file defines one focused server function. Sourced with local=TRUE so
  # the function definitions are scoped to this calling environment.
  source("modules/DataOverview/04_01_DataOverview_MainPlot_axis.R",        local = TRUE)
  source("modules/DataOverview/04_01_DataOverview_MainPlot_gene_input.R",  local = TRUE)
  source("modules/DataOverview/04_01_DataOverview_MainPlot_filter.R",      local = TRUE)
  source("modules/DataOverview/04_01_DataOverview_MainPlot_selection.R",   local = TRUE)
  source("modules/DataOverview/04_01_DataOverview_MainPlot_plot.R",        local = TRUE)

  # MainPlot is only meaningful for Data.Class 'B' (comparison/DEG) datasets.
  # Gate df_ex here, once, instead of in every sub-file: each sub-file already
  # has its own "no data loaded" guard (or, in filter.R, a colnames-existence
  # guard), so handing them NULL when data_type isn't 'B' makes every panel
  # fall back to its normal empty state - no sub-file changes needed.
  df_ex_gated <- reactive({
    if (is.null(data_type()) || data_type() != "B") NULL else df_ex()
  })

  # --- [2] Axis dropdowns ----------------------------------------------------
  # Registers renderUI for output$Scat.X and output$Scat.Y.
  mainplot_axis_server(input, output, session, df_ex_gated)

  # --- [3] Manual gene input -------------------------------------------------
  # Returns: Interesting_gene, Interesting_gene2, df_genes_interest (reactiveVals)
  gene_inputs <- mainplot_gene_input_server(input, output, session, df_ex_gated)

  # --- [4] Gene filtering (threshold / pathway / custom) -------------------
  # Returns: df_outliers, df_outliers_pathway, df_genes_custom_geneset
  filter_outputs <- mainplot_filter_server(input, output, session, df_ex_gated, Original_geneset_list)

  # --- [5] Brush selection ---------------------------------------------------
  # Returns: Overview_selected_table (used downstream by GO analysis)
  selection_outputs <- mainplot_selection_server(input, output, session, df_ex_gated)

  # --- [6] Scatter plot rendering -------------------------------------------
  # Receives all reactive highlight data from steps 3 and 4.
  mainplot_plot_server(
    input, output, session, df_ex_gated,
    gene_inputs$Interesting_gene,
    gene_inputs$Interesting_gene2,
    filter_outputs$df_outliers,
    filter_outputs$df_outliers_pathway,
    filter_outputs$df_genes_custom_geneset
  )

  # --- [7] Return values for downstream modules ------------------------------
  # df_outliers and Overview_selected_table are consumed by GO analysis.
  list(
    df_outliers             = filter_outputs$df_outliers,
    df_outliers_pathway     = filter_outputs$df_outliers_pathway,
    df_genes_custom_geneset = filter_outputs$df_genes_custom_geneset,
    Overview_selected_table = selection_outputs$Overview_selected_table
  )
}
