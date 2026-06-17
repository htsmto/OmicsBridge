# =============================================================================
# Epigenome - Profile Plot: Orchestrator
# File: modules/Epigenome/01_Epigenome_profile_server.R
# Purpose: Wires together the data and plot sub-modules for the Epigenome
#          Profile Plot. Source the sub-files and call the sub-module
#          functions here.
# Edit this file when: adding new sub-modules, changing how reactive values
#                       are passed between data and plot, or restructuring
#                       the overall module layout.
# Libraries required: see libraries_Epigenome.R
# =============================================================================

# Sub-module sources
source('modules/Epigenome/01_Epigenome_profile_data.R', local = TRUE)
source('modules/Epigenome/01_Epigenome_profile_plot.R', local = TRUE)


Epigenome_profile_server <- function(input, output, session, Dataset) {
    # Data sub-module: BigWig loading, genomic region preparation
    data_vals <- epigenome_profile_data_server(input, output, session, Dataset)

    # Plot sub-module: EnrichedHeatmap rendering
    epigenome_profile_plot_server(input, output, session,
        heatmap_data_list = data_vals$heatmap_data_list,
        isCalculating     = data_vals$isCalculating
    )
}
