# =============================================================================
# Clinical - Expression Comparison Server (Orchestrator)
# File: modules/Clinical/06_clinical_ExpressionCompare_server.R
# Purpose: Compares gene expression across patient sub-groups (e.g. subtypes,
#          treatment arms, high/low metadata categories). Produces:
#            - Box / violin plots per group
#            - Statistical test results (t-test, Wilcoxon, ANOVA, Kruskal)
#            - Downloadable result table
# Edit this file when: changing the statistical test, plot type,
#                       grouping variable logic, or multiple-testing correction.
# =============================================================================

clinical_ExpressionCompare_server <- function(input, output, session, Gene_expression, Meta_data, Custom_genesets){
    source("modules/Clinical/06_clinical_ExpressionCompare_data.R", local = TRUE)
    source("modules/Clinical/06_clinical_ExpressionCompare_plot.R", local = TRUE)

    vals <- expr_compare_data_server(input, output, session, Gene_expression, Meta_data, Custom_genesets)

    expr_compare_plot_server(
        input, output, session,
        isCalculating                           = vals$isCalculating,
        Expression_compare_test_result_table    = vals$Expression_compare_test_result_table,
        Expression_compare_pivot_table_for_plot = vals$Expression_compare_pivot_table_for_plot
    )
}
