# =============================================================================
# DataOverview - MainPlot: Manual Gene Input
# File: modules/DataOverview/04_01_DataOverview_MainPlot_gene_input.R
# Purpose: Handles the two free-text gene-of-interest inputs (Input 1 and
#          Input 2). Validates each gene name against df_ex(), reports which
#          genes were found or not found, and builds a combined data table for
#          display and download.
# Edit this file when: changing gene input validation logic, the display table,
#                       or the download handler for manually entered genes.
# =============================================================================

mainplot_gene_input_server <- function(input, output, session, df_ex) {

  # --- [1] Gene Input 1 ------------------------------------------------------
  # Parses newline-separated gene names typed into `input$target_gene`.
  # Reports how many matched the dataset; stores the matched subset in
  # Interesting_gene() which is used by the plot for colour highlighting.

  Scatter_interesting_gene_status <- reactiveVal(NULL)
  output$Scatter_interesting_gene_status <- renderText({ Scatter_interesting_gene_status() })

  Interesting_gene <- reactiveVal(NULL)
  observe({
    # Guard: skip if no data or empty input
    if (length(input$target_gene) == 0 || is.null(input$target_gene) ||
        length(df_ex()) == 0 || is.null(df_ex())) {
      Interesting_gene(NULL)
      return()
    }
    df_main_plot <- df_ex()

    if (nchar(input$target_gene) == 0 || gsub("\\s", "", input$target_gene) == "") {
      Scatter_interesting_gene_status("Please input the gene names line by line.")
      Interesting_gene(NULL)
      return()
    }

    # Split on newlines and check membership in the dataset
    input_genes   <- unlist(strsplit(input$target_gene, split = "\n"))
    genes_in_data <- input_genes[input_genes %in% df_main_plot$id]
    not_found     <- input_genes[!input_genes %in% df_main_plot$id]

    # Build a status message listing any genes not found
    msg_not_found <- if (length(not_found) > 0)
      paste0("\nThe following gene(s) are not found in the data: \n", paste(not_found, collapse = ", "))
    else NULL

    if (length(genes_in_data) == 0) {
      Scatter_interesting_gene_status(msg_not_found)
      Interesting_gene(NULL)
    } else {
      Scatter_interesting_gene_status(paste0("You have inputted ", length(genes_in_data), " genes. \n", msg_not_found))
      Interesting_gene(genes_in_data)
    }
  })


  # --- [2] Gene Input 2 (optional second set) --------------------------------
  # Only active when the user turns on `input$main_plot_target_genes_2`.
  # Identical validation logic as Input 1; stored in Interesting_gene2().

  Scatter_interesting_gene_status2 <- reactiveVal(NULL)
  output$Scatter_interesting_gene_status2 <- renderText({ Scatter_interesting_gene_status2() })

  Interesting_gene2 <- reactiveVal(NULL)
  observe({
    # Guard: switch is off or no data
    if (length(input$main_plot_target_genes_2) == 0 || is.null(input$main_plot_target_genes_2) ||
        input$main_plot_target_genes_2 == FALSE) {
      Interesting_gene2(NULL)
      return()
    }
    if (length(input$main_plot_target_genes_2_input) == 0 || is.null(input$main_plot_target_genes_2_input) ||
        length(df_ex()) == 0 || is.null(df_ex())) {
      Interesting_gene2(NULL)
      return()
    }
    df_main_plot <- df_ex()

    if (nchar(input$main_plot_target_genes_2_input) == 0 ||
        gsub("\\s", "", input$main_plot_target_genes_2_input) == "") {
      Scatter_interesting_gene_status2("Please input the gene names line by line.")
      Interesting_gene2(NULL)
      return()
    }

    input_genes   <- unlist(strsplit(input$main_plot_target_genes_2_input, split = "\n"))
    genes_in_data <- input_genes[input_genes %in% df_main_plot$id]
    not_found     <- input_genes[!input_genes %in% df_main_plot$id]

    msg_not_found <- if (length(not_found) > 0)
      paste0("\nThe following gene(s) are not found in the data: \n", paste(not_found, collapse = ", "))
    else NULL

    if (length(genes_in_data) == 0) {
      Scatter_interesting_gene_status2(msg_not_found)
      Interesting_gene2(NULL)
    } else {
      Scatter_interesting_gene_status2(paste0("You have inputted ", length(genes_in_data), " genes. \n", msg_not_found))
      Interesting_gene2(genes_in_data)
    }
  })


  # --- [3] Combined gene-of-interest table ----------------------------------
  # Merges Input 1 and Input 2 rows into a single data frame for display.
  # Shown when the user enables the "Show gene info" toggle.

  df_genes_interest <- reactiveVal(NULL)
  observe({
    df_main_plot <- df_ex()
    df_tmp <- df_main_plot[df_main_plot$id %in% Interesting_gene(), ]
    if (!is.null(Interesting_gene2())) {
      df_tmp2 <- df_main_plot[df_main_plot$id %in% Interesting_gene2(), ]
      df_tmp  <- rbind(df_tmp, df_tmp2)
    }
    df_genes_interest(df_tmp)
  })

  # Display table
  output$Interesting_gene_outFile <- renderDataTable({
    if (length(input$show_entered_gene_info) == 0 || is.null(input$show_entered_gene_info)) return()
    if (!input$show_entered_gene_info) return()
    if (length(df_genes_interest()) == 0 || is.null(df_genes_interest())) return()
    datatable(data.frame(df_genes_interest(), check.names = FALSE),
              options = list(scrollX = TRUE, pageLength = 10))
  })

  # Download handler for the gene-of-interest table
  output$Interesting_gene_download <- downloadHandler(
    filename = function() { "Interesting_gene_table.csv" },
    content  = function(fname) { write.csv(df_genes_interest(), fname) }
  )


  # --- [4] Return reactive values -------------------------------------------
  # Returned to the orchestrator so the plot server can consume them.
  list(
    Interesting_gene  = Interesting_gene,
    Interesting_gene2 = Interesting_gene2,
    df_genes_interest = df_genes_interest
  )
}
