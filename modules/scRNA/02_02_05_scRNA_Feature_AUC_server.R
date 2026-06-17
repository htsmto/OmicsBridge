# =============================================================================
# scRNA - AUCell Gene Set Activity: Orchestrator
# File: modules/scRNA/02_02_05_scRNA_Feature_AUC_server.R
# Purpose: Wires together the calc and plot sub-modules for the scRNA AUC
#          feature scoring. Source the sub-files and call the sub-module
#          functions here.
# Edit this file when: adding new sub-modules, changing how reactive values
#                       are passed between calc and plot, or restructuring
#                       the overall module layout.
# Libraries required: AUCell (loaded via Seurat environment)
# =============================================================================

suppressMessages(library(AUCell))

# Sub-module sources
source('modules/scRNA/02_02_05_scRNA_Feature_AUC_calc.R', local = TRUE)
source('modules/scRNA/02_02_05_scRNA_Feature_AUC_plot.R', local = TRUE)


scRNA_Feature_server_AUC <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
    # Calc sub-module: AUCell scoring, reactive data frames for UMAP and violin
    calc_vals <- scrna_auc_calc_server(input, output, session,
        Seurat_object    = Seurat_object,
        Input_is_ready   = Input_is_ready,
        gene_list_mannual = gene_list_mannual,
        gene_list_custom  = gene_list_custom
    )

    # Plot sub-module: UMAP and violin plot rendering with AUC score overlay
    scrna_auc_plot_server(input, output, session,
        Seurat_object = Seurat_object,
        umap_AUC      = calc_vals$umap_AUC,
        violin_AUC    = calc_vals$violin_AUC,
        isCalculating = calc_vals$isCalculating
    )
}
