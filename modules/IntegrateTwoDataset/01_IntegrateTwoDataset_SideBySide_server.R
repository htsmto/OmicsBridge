# =============================================================================
# IntegrateTwoDataset - Side-By-Side View Server (Orchestrator)
# File: modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_server.R
# Purpose: Entry point. Sources data, plot and table sub-files, wires data flow.
# Edit this file when: changing data flow between data, plot and table sub-modules,
#                       or the return value consumed by downstream modules.
# =============================================================================

IntegrateTwoDataset_SideBySide_server <- function(input, output, session) {
    source("modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_data.R",  local = TRUE)
    source("modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_plot.R",  local = TRUE)
    source("modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_table.R", local = TRUE)

    data_vals <- side_by_side_data_server(input, output, session)

    side_by_side_plot_server(
        input, output, session,
        df_data1       = data_vals$df_data1,
        df_data2       = data_vals$df_data2,
        data1_outliers = data_vals$data1_outliers,
        data2_outliers = data_vals$data2_outliers
    )

    data1_plus_data2 <- side_by_side_table_server(
        input, output, session,
        df_data1       = data_vals$df_data1,
        df_data2       = data_vals$df_data2,
        data1_outliers = data_vals$data1_outliers,
        data2_outliers = data_vals$data2_outliers
    )

    return(data1_plus_data2)
}
