# =============================================================================
# DatasetsCompare - Single Gene Comparison: Orchestrator
# File: modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_server.R
# Purpose: Orchestrates the data and plot sub-modules for cross-dataset
#          single-gene comparison.
# Edit this file when: changing how sub-modules are wired together or adding
#                       new sub-modules to this feature.
# =============================================================================

DatasetsCompare_CompareOneGene_server <- function(input, output, session, selected_datasets_table, Custom_genesets){
    source("modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_data.R", local = TRUE)
    source("modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_plot.R", local = TRUE)

    data_vals <- compare_one_gene_data_server(input, output, session, selected_datasets_table, Custom_genesets)

    compare_one_gene_plot_server(
        input, output, session,
        used_genes           = data_vals$used_genes,
        all_comapring_tables = data_vals$all_comapring_tables,
        Y_axis_name          = data_vals$Y_axis_name,
        colour_name          = data_vals$colour_name
    )
}
