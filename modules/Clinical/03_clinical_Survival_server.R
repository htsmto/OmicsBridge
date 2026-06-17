# =============================================================================
# Clinical - Survival Analysis Server (Orchestrator)
# File: modules/Clinical/03_clinical_Survival_server.R
# Purpose: Entry point for the Survival Analysis sub-module. Sources the three
#          sub-files and wires their reactive values together.
# Edit this file when: changing the overall data flow between input,
#                      calculation, and plot sub-modules.
# =============================================================================

clinical_Survival_server <- function(input, output, session, ex_table, surv_table, meta_table, Custom_genesets) {

  source("modules/Clinical/03_clinical_Survival_inputs.R", local = TRUE)
  source("modules/Clinical/03_clinical_Survival_calc.R",   local = TRUE)
  source("modules/Clinical/03_clinical_Survival_plot.R",   local = TRUE)

  # --- [1] Inputs and settings -------------------------------------------------
  input_vals <- survival_inputs_server(input, output, session, ex_table, surv_table, meta_table, Custom_genesets)

  # --- [2] KM / Cox calculation ------------------------------------------------
  calc_vals <- survival_calc_server(
    input, output, session, ex_table, surv_table, meta_table,
    input_vals$survival_input_genes,
    input_vals$top_X_percent,
    input_vals$bottom_X_percent,
    input_vals$top_sample_name,
    input_vals$bottom_sample_name,
    input_vals$All_sample_flag,
    input_vals$filtered_sample_ids,
    input_vals$Clinical_Survival_input_status
  )

  # --- [3] Plots and table -----------------------------------------------------
  survival_plot_server(
    input, output, session, ex_table,
    calc_vals$isCalculating,
    calc_vals$df_Suv_p_and_HR,
    calc_vals$plot_lists
  )
}
