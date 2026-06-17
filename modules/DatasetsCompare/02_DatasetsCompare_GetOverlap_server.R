# =============================================================================
# DatasetsCompare - Gene Overlap: Orchestrator
# File: modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_server.R
# Purpose: Orchestrates the calc and plot sub-modules for Venn/overlap analysis
#          across selected datasets.
# Edit this file when: changing how sub-modules are wired together or adding
#                       new sub-modules to this feature.
# =============================================================================

DatasetsCompare_GetOverlap_server <- function(input, output, session, selected_datasets_table){
    source("modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_calc.R", local = TRUE)
    source("modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_plot.R", local = TRUE)

    calc_vals <- get_overlap_calc_server(input, output, session, selected_datasets_table)

    get_overlap_plot_server(
        input, output, session,
        overlapped_genes_table   = calc_vals$overlapped_genes_table,
        isCalculating_ovelap_hit = calc_vals$isCalculating_ovelap_hit
    )
}
