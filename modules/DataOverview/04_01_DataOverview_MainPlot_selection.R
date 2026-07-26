# =============================================================================
# DataOverview - MainPlot: Brush Selection
# File: modules/DataOverview/04_01_DataOverview_MainPlot_selection.R
# Purpose: Handles plot-brush interactions — when the user draws a selection
#          rectangle on the scatter plot, the genes inside that area are
#          extracted, shown in a table, and made available for download.
#          The selection result (Overview_selected_table) is also returned to
#          the GO analysis module.
# Edit this file when: changing how brushed genes are displayed, adding extra
#                       columns to the selection table, or modifying the download format.
# =============================================================================

mainplot_selection_server <- function(input, output, session, df_ex) {

  # --- [1] Brush-based gene selection ----------------------------------------
  # Uses Shiny's brushedPoints() to extract all data rows whose (x, y)
  # coordinates fall within the drawn rectangle.
  # Returns NULL when: no data loaded, axes not chosen, or no brush drawn.

  outFile2_status <- reactiveVal(NULL)
  output$outFile2_status <- renderText({ outFile2_status() })

  Overview_selected_table <- reactiveVal(NULL)
  observe({
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      Overview_selected_table(NULL)
      outFile2_status("The data is not loaded. Please check the data and try again.")
      return()
    }
    if (length(input$scat.y) == 0 || input$scat.y == "None" ||
        length(input$scat.x) == 0 || input$scat.x == "None") {
      Overview_selected_table(NULL)
      outFile2_status("Please select both X and Y axes to show the plot and select genes.")
      return()
    }
    if (!(input$scat.x %in% colnames(df_ex())) || !(input$scat.y %in% colnames(df_ex()))) {
      Overview_selected_table(NULL)
      outFile2_status("The selected axes are not found in the current dataset. Please re-select the X and Y axes.")
      return()
    }
    if (length(input$plot_brush) == 0 || is.null(input$plot_brush)) {
      Overview_selected_table(NULL)
      outFile2_status("Please select an area in the plot to show the genes in that area.")
      return()
    }

    res <- brushedPoints(df_ex(), input$plot_brush,
                         xvar = input$scat.x, yvar = input$scat.y)
    if (nrow(res) == 0) {
      outFile2_status("The selected area in the plot will be shown here.")
      Overview_selected_table(NULL)
    } else {
      outFile2_status(NULL)
      Overview_selected_table(res)
    }
  })


  # --- [2] Display selected genes as table ----------------------------------
  output$outFile2 <- renderDataTable({
    if (is.null(Overview_selected_table())) return(NULL)
    datatable(Overview_selected_table(),
              options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
  })


  # --- [3] Download selected genes ------------------------------------------
  output$selected_download <- downloadHandler(
    filename = function() { "selected_gene_table.tsv" },
    content  = function(fname) {
      write.table(Overview_selected_table(), fname, sep = "\t", quote = FALSE, row.names = FALSE)
    }
  )


  # --- [4] Text list of selected gene names ---------------------------------
  output$selected_gene_list <- renderText({
    if (is.null(Overview_selected_table())) return(NULL)
    paste(na.omit(Overview_selected_table()$id), collapse = "\n")
  })


  # --- Return ----------------------------------------------------------------
  # Overview_selected_table is consumed by the GO analysis module.
  list(Overview_selected_table = Overview_selected_table)
}
