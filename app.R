# =============================================================================
# OmicsBridge - Main Application Entry Point
# File: app.R
# Purpose: Assembles the Shiny UI from modular components, and wires up the
#          server with lazy-loading so that heavy modules (Seurat, clusterProfiler,
#          etc.) are only loaded the first time a user navigates to that tab.
#
# Edit this file when:
#   - Adding a new top-level tab / module
#   - Changing global upload size limits
#   - Adjusting which modules are loaded eagerly vs. lazily
# =============================================================================

# --- [1] Global options -------------------------------------------------------
# Allow large file uploads (e.g., count matrices, BAM-derived tables).
# 10 GB limit; adjust if needed.
options(shiny.maxRequestSize = 10000 * 1024^2)


# --- [2] Core libraries & UI components --------------------------------------
# libraries.R loads only the lightweight Shiny-related packages needed to
# render the shell of the app (shiny, shinydashboard, shinyjs, etc.).
# Heavy bioinformatics libraries are sourced per-module below.
source('libraries/libraries.R')

source("ui/header.R")   # dashboardHeader definition
source("ui/sidebar.R")  # dashboardSidebar with menu items
source("ui/body.R")     # dashboardBody: sources all module wrappers and
                        # defines each tabItem — UI files only at this stage


# --- [3] Assemble UI ----------------------------------------------------------
# Inject custom CSS / JS, then wrap header + sidebar + body into the standard
# shinydashboard layout.
ui <- tagList(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
        tags$script(src = "custom.js")
    ),
    dashboardPage(header, sidebar, body)
)


# --- [4] Server function ------------------------------------------------------
server <- function(input, output, session) {

    # --- [4-1] Always-on modules --------------------------------------------
    # These modules are lightweight and required as soon as the app starts
    # (database browsing, gene set management, and documentation).
    databaseModuleServer("db")
    originalgenesetModuleServer("original_geneset")
    wiki_documentModuleServer("wiki_document")


    # --- [4-2] Lazy-loading tracker ------------------------------------------
    # `loaded` is a reactiveValues object used as a per-session flag store.
    # Each tab name is used as a key; once set to TRUE the server for that
    # module will not be registered again, preventing duplicate reactive chains.
    loaded <- reactiveValues()


    # --- [4-3] Tab-driven lazy loading ----------------------------------------
    # When the user navigates to a tab for the first time:
    #   1. Set the loaded flag to prevent re-execution on subsequent visits.
    #   2. Source the module's library file (if it has one).
    #   3. Call moduleServer — this registers the reactive logic for that tab.
    #   4. Wrap in tryCatch so a broken module shows a notification rather than
    #      crashing the whole session.
    #   5. Use withProgress for tabs that load slowly so the user gets feedback.
    observeEvent(input$sidebar, {
        tab <- input$sidebar

        # Skip if this tab's server has already been registered.
        if (isTRUE(loaded[[tab]])) return()
        loaded[[tab]] <- TRUE

        if (tab == "Data_Overview") {
            # Transcriptome analysis: loads clusterProfiler, fgsea, GSVA, etc.
            withProgress(message = "Loading transcriptome analysis tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_DataOverview.R", local = TRUE)
                    dataoverviewModuleServer("data_overview")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Data Overview module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "scRNA") {
            # scRNA-seq: Seurat can take 20-40 s to load on first use.
            withProgress(message = "Loading Seurat library — this may take ~30 seconds on first use...", value = 0.2, {
                tryCatch({
                    suppressMessages(library(Seurat))
                    setProgress(0.8, message = "Initializing scRNA module...")
                    scRNAModuleServer("scRNA")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load scRNA module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Clinical_dataset") {
            # Clinical analysis: survival, deconvolution, mutation plotting, etc.
            withProgress(message = "Loading clinical analysis tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_Clinical.R", local = TRUE)
                    clinicalModuleServer("clinical")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Clinical module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Tools") {
            # Utility tools: gene ID conversion, locus finder, Venn diagrams, etc.
            tryCatch({
                source("libraries/libraries_tools.R", local = TRUE)
                toolsModuleServer("tools")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Tools module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })

        } else if (tab == "igv") {
            # Epigenome: IGV browser, motif scanning, genome-wide visualisation.
            withProgress(message = "Loading epigenome visualisation tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_Epigenome.R", local = TRUE)
                    EpigenomeModuleServer("igv")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Epigenome module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Compare_across_datasets") {
            # Cross-dataset comparison: relatively lightweight.
            tryCatch({
                DatasetsCompareModuleServer("datasets_compare")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Datasets Compare module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })

        } else if (tab == "Integrate_two_dataset") {
            # Side-by-side integration of two datasets.
            tryCatch({
                source('libraries/libraries_IntegrateTwoDataset.R', local = TRUE)
                IntegrateTwoDatasetModuleServer("integrate_two_dataset")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Integrate Two Datasets module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })
        }
    })
}


# --- [5] Launch the app -------------------------------------------------------
shinyApp(ui, server)
