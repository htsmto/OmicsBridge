# =============================================================================
# Clinical - Mutation Visualisation Server  [ORCHESTRATOR]
# File: modules/Clinical/05_clinical_Mutation_server.R
# Purpose: Entry point for the mutation module. Sources sub-modules and wires
#          them together by passing shared reactive values from the data layer
#          to the plot layers.
#
#          Sub-modules:
#            05_clinical_Mutation_data.R      — gene inputs, sample filtering,
#                                               frequency calculation, freq table
#            05_clinical_Mutation_waterfall.R — frequency bar plot,
#                                               Kaplan-Meier survival plot
#            05_clinical_Mutation_oncoprint.R — expression comparison plot
#
# Edit this file when: adding new sub-modules or changing how shared reactive
#                      values are threaded between sub-modules.
# Libraries required: maftools (loaded via libraries_Clinical.R)
# =============================================================================

clinical_Mutation_server <- function(input, output, session, ex_table, survival_table, meta_table, mutation_table, Custom_genesets) {

    source("modules/Clinical/05_clinical_Mutation_data.R",      local = TRUE)
    source("modules/Clinical/05_clinical_Mutation_waterfall.R", local = TRUE)
    source("modules/Clinical/05_clinical_Mutation_oncoprint.R", local = TRUE)

    # Data layer — returns shared reactive values
    data_vals <- mutation_data_server(
        input, output, session,
        ex_table, survival_table, meta_table, mutation_table, Custom_genesets
    )

    # Frequency bar plot + Kaplan-Meier survival plot
    mutation_waterfall_server(
        input, output, session,
        ex_table, survival_table, meta_table, mutation_table, Custom_genesets,
        mut_freq_table      = data_vals$mut_freq_table,
        isCalculating       = data_vals$isCalculating,
        All_sample_flag     = data_vals$All_sample_flag,
        filtered_sample_ids = data_vals$filtered_sample_ids
    )

    # Expression comparison plot
    mutation_oncoprint_server(
        input, output, session,
        ex_table, survival_table, meta_table, mutation_table, Custom_genesets,
        mut_freq_table      = data_vals$mut_freq_table,
        isCalculating       = data_vals$isCalculating,
        All_sample_flag     = data_vals$All_sample_flag,
        filtered_sample_ids = data_vals$filtered_sample_ids
    )

}
