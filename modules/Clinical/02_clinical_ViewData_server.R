# =============================================================================
# Clinical - View Data Server (Orchestrator)
# File: modules/Clinical/02_clinical_ViewData_server.R
# Purpose: Entry point. Sources load and table sub-files, wires data flow.
# Edit this file when: changing data flow between load and table sub-modules,
#                       or adding new data types passed downstream.
# =============================================================================

clinical_ViewData_server <- function(input, output, session, dataset_name, ex_path, surv_path, meta_path, mut_path) {
    source("modules/Clinical/02_clinical_ViewData_load.R",  local = TRUE)
    source("modules/Clinical/02_clinical_ViewData_table.R", local = TRUE)

    load_vals <- viewdata_load_server(input, output, session, dataset_name, ex_path, surv_path, meta_path, mut_path)

    viewdata_table_server(
        input, output, session,
        gene_expression_data = load_vals$gene_expression_data,
        survival_data        = load_vals$survival_data,
        meta_data            = load_vals$meta_data,
        mutation_data        = load_vals$mutation_data,
        meta_path            = meta_path
    )

    ## return the read data tables
        return(list(
            Gene_expression = load_vals$gene_expression_data,
            Survival        = load_vals$survival_data,
            Meta_data       = load_vals$meta_data,
            Mutation_data   = load_vals$mutation_data
        ))

    ##
}
