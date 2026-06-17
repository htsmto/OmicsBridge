# =============================================================================
# Epigenome - Motif Scan: Orchestrator
# File: modules/Epigenome/05_Epigenome_motifScan_server.R
# Purpose: Wires together the scan and plot sub-modules for the Epigenome
#          Motif Scan. Source the sub-files and call the sub-module
#          functions here.
# Edit this file when: adding new sub-modules, changing how reactive values
#                       are passed between scan and plot, or restructuring
#                       the overall module layout.
# Libraries required: see libraries_Epigenome.R
# =============================================================================

# Sub-module sources
source('modules/Epigenome/05_Epigenome_motifScan_scan.R', local = TRUE)
source('modules/Epigenome/05_Epigenome_motifScan_plot.R', local = TRUE)


Epigenome_motifScan_server <- function(input, output, session) {
    # Scan sub-module: input UI, peak/sequence validation, motifEnrichment
    scan_vals <- motif_scan_server(input, output, session)

    # Plot sub-module: result table, logo plot, significant motif list, download
    motif_scan_plot_server(input, output, session,
        Motif_scan_result             = scan_vals$Motif_scan_result,
        isCalculating_Motif_analysis  = scan_vals$isCalculating_Motif_analysis,
        Motif_analysis_plot_status    = scan_vals$Motif_analysis_plot_status
    )
}
