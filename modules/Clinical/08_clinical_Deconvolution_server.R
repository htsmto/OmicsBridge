# =============================================================================
# Clinical - Cell-Type Deconvolution Server (Orchestrator)
# File: modules/Clinical/08_clinical_Deconvolution_server.R
# Purpose: Entry point for the Deconvolution sub-module. Sources the two
#          sub-files and wires their reactive values together.
# Edit this file when: changing the overall data flow between calculation
#                      and plot sub-modules.
# =============================================================================

clinical_Deconvolution_server <- function(input, output, session, Gene_expression, Survival, Meta_data, Mutation_data, Custom_genesets) {

  source("modules/Clinical/08_clinical_Deconvolution_calc.R", local = TRUE)
  source("modules/Clinical/08_clinical_Deconvolution_plot.R", local = TRUE)
  source("modules/Clinical/08_clinical_Deconvolution_mutation_calc.R", local = TRUE)
  source("modules/Clinical/08_clinical_Deconvolution_mutation_plot.R", local = TRUE)

  # --- [1] Deconvolution calculation -------------------------------------------
  calc_vals <- deconvolution_calc_server(input, output, session, Gene_expression, Survival, Meta_data, Custom_genesets)

  # --- [2] Plots and tables ----------------------------------------------------
  deconvolution_plot_server(
    input, output, session,
    Gene_expression,
    calc_vals$deconv_table,
    calc_vals$deconv_long,
    calc_vals$isCalculating_deconv_long,
    calc_vals$Deconvolution_gene_correlation,
    calc_vals$isCalculating_Deconvolution_gene_correlation,
    calc_vals$All_sample_flag,
    calc_vals$filtered_sample_ids
  )

  # --- [3] Association with mutations ------------------------------------------
  mutation_vals <- deconvolution_mutation_calc_server(input, output, session, calc_vals$deconv_table, Mutation_data, Custom_genesets)
  deconvolution_mutation_plot_server(
    input, output, session,
    Mutation_data,
    mutation_vals$Deconvolution_mutation_result,
    mutation_vals$isCalculating_Deconvolution_mutation,
    mutation_vals$Deconvolution_mutation_plot_info
  )
}
