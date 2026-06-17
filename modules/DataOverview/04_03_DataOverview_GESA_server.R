# =============================================================================
# DataOverview - GSEA Server (Orchestrator)
# File: modules/DataOverview/04_03_DataOverview_GESA_server.R
# Purpose: Entry point. Sources calc and plot sub-files, wires data flow.
# Edit this file when: changing data flow between calc and plot sub-modules.
# =============================================================================

dataoverview_gsea_Server <- function(input, output, session, df_ex, Original_geneset_list) {
    source("modules/DataOverview/04_03_DataOverview_GESA_calc.R", local = TRUE)
    source("modules/DataOverview/04_03_DataOverview_GESA_plot.R", local = TRUE)

    calc_vals <- gsea_calc_server(input, output, session, df_ex, Original_geneset_list)

    gsea_plot_server(
        input, output, session,
        df_ex                     = df_ex,
        GSEA_results              = calc_vals$GSEA_results,
        GSEA_Gene_set_after_start = calc_vals$GSEA_Gene_set_after_start,
        ranked_score              = calc_vals$ranked_score,
        isCalculating             = calc_vals$isCalculating
    )
}
