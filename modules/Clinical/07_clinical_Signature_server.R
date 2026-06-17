# =============================================================================
# Clinical - Signature: Orchestrator
# File: modules/Clinical/07_clinical_Signature_server.R
# Purpose: Entry point for the Gene Signature Analysis module. Sources the
#          calculation and plot sub-modules and wires their reactive values
#          together.
# Edit this file when: changing which sub-modules are loaded or how reactive
#                      values are passed between calc and plot layers.
# =============================================================================

clinical_Signature_server <- function(input, output, session, Gene_expression, surv_table, meta_table, Custom_genesets) {

    source("modules/Clinical/07_clinical_Signature_calc.R",  local = TRUE)
    source("modules/Clinical/07_clinical_Signature_plot.R",  local = TRUE)

    calc_vals <- signature_calc_server(
        input          = input,
        output         = output,
        session        = session,
        Gene_expression = Gene_expression,
        surv_table     = surv_table,
        meta_table     = meta_table,
        Custom_genesets = Custom_genesets
    )

    signature_plot_server(
        input          = input,
        output         = output,
        session        = session,
        meta_table     = meta_table,
        surv_table     = surv_table,
        signature_table             = calc_vals$signature_table,
        isCalculating               = calc_vals$isCalculating,
        All_sample_flag             = calc_vals$All_sample_flag,
        filtered_sample_ids_reactive = calc_vals$filtered_sample_ids_reactive
    )

}
