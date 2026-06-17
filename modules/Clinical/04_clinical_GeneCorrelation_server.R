# =============================================================================
# Clinical - Gene Correlation Server (Orchestrator)
# File: modules/Clinical/04_clinical_GeneCorrelation_server.R
# Purpose: Entry point for the Gene Correlation sub-module. Sources the two
#          sub-files and wires their reactive values together.
# Edit this file when: changing the overall data flow between calculation
#                      and plot sub-modules.
# =============================================================================

clinical_GeneCorrelation_server <- function(input, output, session, ex_table, meta_table, Custom_genesets) {

  source("modules/Clinical/04_clinical_GeneCorrelation_calc.R", local = TRUE)
  source("modules/Clinical/04_clinical_GeneCorrelation_plot.R", local = TRUE)

  # --- [1] Correlation calculation ---------------------------------------------
  calc_vals <- gene_correlation_calc_server(input, output, session, ex_table, meta_table, Custom_genesets)

  # --- [2] Scatter plot and result table ----------------------------------------
  gene_correlation_plot_server(
    input, output, session,
    ex_table,
    calc_vals$Correlation_result_list,
    calc_vals$isCalculating,
    calc_vals$All_sample_flag,
    calc_vals$filtered_sample_ids
  )
}
