# =============================================================================
# DataOverview - MainPlot: Gene Filtering (threshold / pathway / custom sets)
# File: modules/DataOverview/04_01_DataOverview_MainPlot_filter.R
# Purpose: Three independent gene-selection methods that highlight points in
#          the main scatter plot:
#   B - Threshold-based filter: keep genes beyond X/Y cutoffs
#   C - Pathway filter: highlight genes belonging to a selected GMT pathway
#   D - Custom geneset filter: highlight genes from the user's custom gene set
#
# All three store their filtered data frames in reactive values that are
# consumed by the plot and returned to downstream modules (e.g. GO analysis).
#
# Edit this file when: changing filter logic, adding new GMT sources,
#                       or modifying how the filtered-gene tables are displayed.
# =============================================================================

mainplot_filter_server <- function(input, output, session, df_ex, Original_geneset_list) {

  ## ---- [B] Threshold-based filter ------------------------------------------
  # Reads X/Y threshold inputs and returns the subset of df_ex() that passes
  # the user-selected comparison operator (>, <, between, outside).

  df_outliers <- reactiveVal(NULL)

  observe({
    # Guard: axes must be selected and filter mode must be 'B'
    if (length(input$scat.y) == 0 || input$scat.y == "None" ||
        length(input$scat.x) == 0 || input$scat.x == "None") {
      df_outliers(NULL)
      return(NULL)
    }

    if (!(input$scat.x %in% colnames(df_ex())) || !(input$scat.y %in% colnames(df_ex()))) {
      df_outliers(NULL)
      return(NULL)
    }

    df_main_plot <- df_ex()

    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "B") {
      df_outliers(NULL)
      return(NULL)
    }

    if (input$How_to_filter == "A") {
      # Mode A inside B: filter by Y threshold then take top/bottom X percentile
      df_main_plot <- df_main_plot[df_main_plot[input$scat.y] >= input$Overviwe_Top_bottom_Y_threshold, ]
      X_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x] >= 0],
                        1 - (input$Overviwe_Top_threshold / 100), na.rm = TRUE)
      Y_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x] <= 0],
                        input$Overviwe_Bottom_threshold / 100, na.rm = TRUE)
      df_main_plot <- df_main_plot[df_main_plot[input$scat.x] > X_thr |
                                   df_main_plot[input$scat.x] < Y_thr, ]
      df_outliers(df_main_plot)

    } else if (input$How_to_filter == "B") {
      # Mode B inside B: filter by explicit X and Y value thresholds
      if (input$Main_scatter_thr_X_method == "A" && input$Main_scatter_thr_Y_method == "A") {
        df_outliers(NULL)
        return(NULL)
      }
      # Apply X threshold (switch over 5 comparison operators)
      df_filtered <- switch(input$Main_scatter_thr_X_method,
        "A" = df_main_plot,
        "B" = df_main_plot[df_main_plot[input$scat.x] >  input$Main_scatter_thr_X1, ],
        "C" = df_main_plot[df_main_plot[input$scat.x] <  input$Main_scatter_thr_X2, ],
        "D" = df_main_plot[(df_main_plot[input$scat.x] > input$Main_scatter_thr_X2) &
                            (df_main_plot[input$scat.x] < input$Main_scatter_thr_X1), ],
        "E" = df_main_plot[(df_main_plot[input$scat.x] < input$Main_scatter_thr_X2) |
                            (df_main_plot[input$scat.x] > input$Main_scatter_thr_X1), ]
      )
      # Apply Y threshold on top of X-filtered result
      df_filtered <- switch(input$Main_scatter_thr_Y_method,
        "A" = df_filtered,
        "B" = df_filtered[df_filtered[input$scat.y] >  input$Main_scatter_thr_Y1, ],
        "C" = df_filtered[df_filtered[input$scat.y] <  input$Main_scatter_thr_Y2, ],
        "D" = df_filtered[(df_filtered[input$scat.y] > input$Main_scatter_thr_Y2) &
                           (df_filtered[input$scat.y] < input$Main_scatter_thr_Y1), ],
        "E" = df_filtered[(df_filtered[input$scat.y] < input$Main_scatter_thr_Y2) |
                           (df_filtered[input$scat.y] > input$Main_scatter_thr_Y1), ]
      )
      df_outliers(df_filtered)
    }
  })

  # Status text and table for filter mode B
  filtered_genes_status <- reactiveVal(NULL)
  output$filtered_genes_status <- renderText({ filtered_genes_status() })

  output$filtered_gene_table <- renderDataTable({
    if (length(input$show_filterin_input_option) == 0 || is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "B" ||
        length(input$show_information) == 0 || is.null(input$show_information) ||
        !input$show_information) {
      filtered_genes_status(NULL)
      return()
    }
    if (length(df_outliers()) == 0 || is.null(df_outliers())) {
      filtered_genes_status("No genes found based on the selected filters.")
      return()
    }
    filtered_genes_status(paste("Number of genes found:", nrow(df_outliers())))
    datatable(data.frame(df_outliers(), check.names = FALSE),
              options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
  })

  output$filtered_gene_list <- renderText({
    paste(na.omit(df_outliers()$id), collapse = "\n")
  })

  output$filtered_download <- downloadHandler(
    filename = function() { "Filtered_genes_in_plot.csv" },
    content  = function(fname) { write.csv(df_outliers(), fname) }
  )


  ## ---- [C] Pathway filter --------------------------------------------------
  # Loads a GMT file (Hallmark human, Hallmark mouse, or user-uploaded custom)
  # and highlights all genes from the selected pathway term.

  Gene_set <- reactiveVal(NULL)
  observe({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "C") {
      Gene_set(NULL)
      return()
    }
    gsc <- switch(input$pathway_dataset_select,
      "HALLMARK (human)" = getGmt("data/h.all.v2023.2.Hs.symbols.gmt"),
      "HALLMARK (mouse)" = getGmt("data/mh.all.v2023.2.Mm.symbols.gmt"),
      "Custom" = {
        tmp <- input$upload_custom_pathway_file
        if (is.null(tmp)) NULL else getGmt(tmp$datapath)
      }
    )
    Gene_set(gsc)
  })

  # Dynamic UI: pathway term selector populated from the loaded GMT object
  output$select_pathway <- renderUI({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "C") return()
    gene_sets_names <- c()
    if (length(Gene_set()) != 0 && !is.null(Gene_set())) {
      for (i in seq_along(Gene_set())) {
        gene_sets_names <- c(gene_sets_names, Gene_set()@.Data[[i]]@setName)
      }
    }
    selectInput(session$ns("select_pathway"), "Select a geneset",
                c("None" = "None", gene_sets_names))
  })

  # Gene list for the selected pathway term
  genes_in_the_pathway <- reactiveVal(NULL)
  observe({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "C") {
      genes_in_the_pathway(NULL)
    } else if (length(input$select_pathway) == 0 || input$select_pathway == "None" ||
               is.null(Gene_set()) || length(Gene_set()) == 0 ||
               !(input$select_pathway %in% names(Gene_set()))) {
      genes_in_the_pathway(NULL)
    } else {
      genes_in_the_pathway(Gene_set()[[input$select_pathway]]@geneIds)
    }
  })

  # Filter the dataset to pathway genes + optional additional X/Y threshold
  df_outliers_pathway <- reactiveVal(NULL)
  not_found_gene  <- reactiveVal(NULL)
  found_gene      <- reactiveVal(NULL)
  filter_method   <- reactiveVal(NULL)

  observe({
    if (length(input$scat.y) == 0 || input$scat.y == "None" ||
        length(input$scat.x) == 0 || input$scat.x == "None") {
      df_outliers_pathway(NULL); not_found_gene(NULL); found_gene(NULL); filter_method(NULL)
      return(NULL)
    }
    if (!(input$scat.x %in% colnames(df_ex())) || !(input$scat.y %in% colnames(df_ex()))) {
      df_outliers_pathway(NULL); not_found_gene(NULL); found_gene(NULL); filter_method(NULL)
      return(NULL)
    }
    if (length(genes_in_the_pathway()) == 0 || is.null(genes_in_the_pathway())) {
      df_outliers_pathway(NULL); not_found_gene(NULL); found_gene(NULL); filter_method(NULL)
      return()
    }

    df_main_plot <- df_ex()
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "C") return()

    genes_found     <- genes_in_the_pathway()[genes_in_the_pathway() %in% df_main_plot$id]
    genes_not_found <- genes_in_the_pathway()[!genes_in_the_pathway() %in% df_main_plot$id]
    not_found_gene(genes_not_found)
    found_gene(genes_found)

    df_pathway <- df_main_plot[df_main_plot$id %in% genes_found, ]

    if (input$Main_scatter_pathway_filter) {
      # Apply additional X threshold
      df_pathway <- switch(input$Main_scatter_pathway_thr_X_method,
        "A" = df_pathway,
        "B" = df_pathway[df_pathway[input$scat.x] >  input$Main_scatter_pathway_thr_X1, ],
        "C" = df_pathway[df_pathway[input$scat.x] <  input$Main_scatter_pathway_thr_X2, ],
        "D" = df_pathway[(df_pathway[input$scat.x] > input$Main_scatter_pathway_thr_X2) &
                          (df_pathway[input$scat.x] < input$Main_scatter_pathway_thr_X1), ],
        "E" = df_pathway[(df_pathway[input$scat.x] < input$Main_scatter_pathway_thr_X2) |
                          (df_pathway[input$scat.x] > input$Main_scatter_pathway_thr_X1), ]
      )
      # Apply additional Y threshold
      df_pathway <- switch(input$Main_scatter_pathway_thr_Y_method,
        "A" = df_pathway,
        "B" = df_pathway[df_pathway[input$scat.y] >  input$Main_scatter_pathway_thr_Y1, ],
        "C" = df_pathway[df_pathway[input$scat.y] <  input$Main_scatter_pathway_thr_Y2, ],
        "D" = df_pathway[(df_pathway[input$scat.y] > input$Main_scatter_pathway_thr_Y2) &
                          (df_pathway[input$scat.y] < input$Main_scatter_pathway_thr_Y1), ],
        "E" = df_pathway[(df_pathway[input$scat.y] < input$Main_scatter_pathway_thr_Y2) |
                          (df_pathway[input$scat.y] > input$Main_scatter_pathway_thr_Y1), ]
      )
      # Build a human-readable description of the applied filter for the status text
      fx <- switch(input$Main_scatter_pathway_thr_X_method,
        "A" = NULL, "B" = paste0("X > ", input$Main_scatter_pathway_thr_X1),
        "C" = paste0("X < ", input$Main_scatter_pathway_thr_X2),
        "D" = paste0("X > ", input$Main_scatter_pathway_thr_X2, " & X < ", input$Main_scatter_pathway_thr_X1),
        "E" = paste0("X < ", input$Main_scatter_pathway_thr_X2, " | X > ", input$Main_scatter_pathway_thr_X1))
      fy <- switch(input$Main_scatter_pathway_thr_Y_method,
        "A" = NULL, "B" = paste0("Y > ", input$Main_scatter_pathway_thr_Y1),
        "C" = paste0("Y < ", input$Main_scatter_pathway_thr_Y2),
        "D" = paste0("Y > ", input$Main_scatter_pathway_thr_Y2, " & Y < ", input$Main_scatter_pathway_thr_Y1),
        "E" = paste0("Y < ", input$Main_scatter_pathway_thr_Y2, " | Y > ", input$Main_scatter_pathway_thr_Y1))
      filter_method(paste(Filter(Negate(is.null), list(fx, fy)), collapse = " & "))
    } else {
      filter_method(NULL)
    }
    df_outliers_pathway(df_pathway)
  })

  # Status + table for pathway mode
  outFile3_pathway_status <- reactiveVal(NULL)
  output$outFile3_pathway_status <- renderText({ outFile3_pathway_status() })

  output$outFile3_pathway <- renderDataTable({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "C" ||
        length(input$show_information_pathway) == 0 ||
        is.null(input$show_information_pathway) ||
        !input$show_information_pathway) {
      outFile3_pathway_status(NULL)
      return()
    }
    if (length(df_outliers_pathway()) == 0 || is.null(df_outliers_pathway())) {
      outFile3_pathway_status("Please set the plot and pathway options. A table of the genes in the pathway that are in the plot will be shown here.")
      return()
    }
    msg_not_found <- if (length(not_found_gene()) > 0 && !is.null(not_found_gene()))
      paste0("\n\nThe following gene(s) in the pathway are not found in the data: \n", paste(not_found_gene(), collapse = ", "))
    else NULL
    msg_filter <- if (input$Main_scatter_pathway_filter && !is.null(filter_method()))
      paste0("\n\nFiltering applied: ", filter_method(), "\nGenes in the pathway after filtering: ", nrow(df_outliers_pathway()))
    else NULL
    outFile3_pathway_status(paste0(
      "Pathway: ", input$select_pathway,
      "\nGenes in the pathway: ", length(genes_in_the_pathway()),
      "\nGenes in the plot: ", length(found_gene()),
      msg_not_found, msg_filter))
    datatable(data.frame(df_outliers_pathway(), check.names = FALSE),
              options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
  })

  output$pathway_gene_list <- renderText({
    paste(na.omit(df_outliers_pathway()$id), collapse = "\n")
  })
  output$pathway_download <- downloadHandler(
    filename = function() { "Pathway_genes_in_plot.csv" },
    content  = function(fname) { write.csv(df_outliers_pathway(), fname) }
  )


  ## ---- [D] Custom geneset filter ------------------------------------------
  # Highlights genes from one of the user's own gene sets stored in
  # Original_geneset_list. Supports the same additional X/Y filter as pathway.

  output$Plot_Gene_set_select_geneset <- renderUI({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "D") return(NULL)
    selectInput(session$ns("Plot_Gene_set_select_geneset"), "Select a custom geneset",
                c("None" = "None", Original_geneset_list()$Geneset.name))
  })

  custom_genes <- reactiveVal(NULL)
  observe({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "D") {
      custom_genes(NULL)
      return()
    }
    if (length(input$Plot_Gene_set_select_geneset) == 0 ||
        input$Plot_Gene_set_select_geneset == "None") {
      custom_genes(NULL)
    } else {
      genes_tmp <- strsplit(
        Original_geneset_list()[
          Original_geneset_list()$Geneset.name %in% input$Plot_Gene_set_select_geneset, ]$Genes,
        split = ", ")[[1]]
      custom_genes(genes_tmp)
    }
  })

  df_genes_custom_geneset <- reactiveVal(NULL)
  not_found_gene_custom   <- reactiveVal(NULL)
  found_gene_custom       <- reactiveVal(NULL)
  filter_method_custom    <- reactiveVal(NULL)

  observe({
    if (length(input$scat.y) == 0 || input$scat.y == "None" ||
        length(input$scat.x) == 0 || input$scat.x == "None") {
      df_genes_custom_geneset(NULL); not_found_gene_custom(NULL)
      found_gene_custom(NULL); filter_method_custom(NULL)
      return(NULL)
    }
    if (!(input$scat.x %in% colnames(df_ex())) || !(input$scat.y %in% colnames(df_ex()))) {
      df_genes_custom_geneset(NULL); not_found_gene_custom(NULL)
      found_gene_custom(NULL); filter_method_custom(NULL)
      return(NULL)
    }
    if (length(custom_genes()) == 0 || is.null(custom_genes())) {
      df_genes_custom_geneset(NULL); not_found_gene_custom(NULL)
      found_gene_custom(NULL); filter_method_custom(NULL)
      return()
    }
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "D") return()

    df_main_plot    <- df_ex()
    genes_found     <- custom_genes()[custom_genes() %in% df_main_plot$id]
    genes_not_found <- custom_genes()[!custom_genes() %in% df_main_plot$id]
    not_found_gene_custom(genes_not_found)
    found_gene_custom(genes_found)

    df_custom <- df_main_plot[df_main_plot$id %in% genes_found, ]

    if (input$Main_scatter_geneset_filter) {
      df_custom <- switch(input$Main_scatter_geneset_thr_X_method,
        "A" = df_custom,
        "B" = df_custom[df_custom[input$scat.x] >  input$Main_scatter_geneset_thr_X1, ],
        "C" = df_custom[df_custom[input$scat.x] <  input$Main_scatter_geneset_thr_X2, ],
        "D" = df_custom[(df_custom[input$scat.x] > input$Main_scatter_geneset_thr_X2) &
                         (df_custom[input$scat.x] < input$Main_scatter_geneset_thr_X1), ],
        "E" = df_custom[(df_custom[input$scat.x] < input$Main_scatter_geneset_thr_X2) |
                         (df_custom[input$scat.x] > input$Main_scatter_geneset_thr_X1), ]
      )
      df_custom <- switch(input$Main_scatter_geneset_thr_Y_method,
        "A" = df_custom,
        "B" = df_custom[df_custom[input$scat.y] >  input$Main_scatter_geneset_thr_Y1, ],
        "C" = df_custom[df_custom[input$scat.y] <  input$Main_scatter_geneset_thr_Y2, ],
        "D" = df_custom[(df_custom[input$scat.y] > input$Main_scatter_geneset_thr_Y2) &
                         (df_custom[input$scat.y] < input$Main_scatter_geneset_thr_Y1), ],
        "E" = df_custom[(df_custom[input$scat.y] < input$Main_scatter_geneset_thr_Y2) |
                         (df_custom[input$scat.y] > input$Main_scatter_geneset_thr_Y1), ]
      )
      fx <- switch(input$Main_scatter_geneset_thr_X_method,
        "A" = NULL, "B" = paste0("X > ", input$Main_scatter_geneset_thr_X1),
        "C" = paste0("X < ", input$Main_scatter_geneset_thr_X2),
        "D" = paste0("X > ", input$Main_scatter_geneset_thr_X2, " & X < ", input$Main_scatter_geneset_thr_X1),
        "E" = paste0("X < ", input$Main_scatter_geneset_thr_X2, " | X > ", input$Main_scatter_geneset_thr_X1))
      fy <- switch(input$Main_scatter_geneset_thr_Y_method,
        "A" = NULL, "B" = paste0("Y > ", input$Main_scatter_geneset_thr_Y1),
        "C" = paste0("Y < ", input$Main_scatter_geneset_thr_Y2),
        "D" = paste0("Y > ", input$Main_scatter_geneset_thr_Y2, " & Y < ", input$Main_scatter_geneset_thr_Y1),
        "E" = paste0("Y < ", input$Main_scatter_geneset_thr_Y2, " | Y > ", input$Main_scatter_geneset_thr_Y1))
      filter_method_custom(paste(Filter(Negate(is.null), list(fx, fy)), collapse = " & "))
    } else {
      filter_method_custom(NULL)
    }
    df_genes_custom_geneset(df_custom)
  })

  outFile3_custom_geneset_status <- reactiveVal(NULL)
  output$outFile3_custom_geneset_status <- renderText({ outFile3_custom_geneset_status() })

  output$outFile3_custom_geneset <- renderDataTable({
    if (length(input$show_filterin_input_option) == 0 ||
        is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option != "D" ||
        length(input$Plot_Gene_setshow_information) == 0 ||
        is.null(input$Plot_Gene_setshow_information) ||
        !input$Plot_Gene_setshow_information) {
      outFile3_custom_geneset_status(NULL)
      return()
    }
    if (length(df_genes_custom_geneset()) == 0 || is.null(df_genes_custom_geneset())) {
      outFile3_custom_geneset_status("Please set the plot and custom gene set options. A table of the genes in the custom gene set that are in the plot will be shown here.")
      return()
    }
    msg_not_found <- if (length(not_found_gene_custom()) > 0 && !is.null(not_found_gene_custom()))
      paste0("\n\nThe following gene(s) in the custom gene set are not found in the data: \n",
             paste(not_found_gene_custom(), collapse = ", "))
    else NULL
    msg_filter <- if (input$Main_scatter_geneset_filter && !is.null(filter_method_custom()))
      paste0("\n\nFiltering applied: ", filter_method_custom(),
             "\nGenes in the custom gene set after filtering: ", nrow(df_genes_custom_geneset()))
    else NULL
    outFile3_custom_geneset_status(paste0(
      "Custom Gene Set: ", input$select_custom_geneset,
      "\nGenes in the custom gene set: ", length(custom_genes()),
      "\nGenes in the plot: ", length(found_gene_custom()),
      msg_not_found, msg_filter))
    datatable(data.frame(df_genes_custom_geneset(), check.names = FALSE),
              options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
  })

  output$Custom_geneset_gene_list <- renderText({
    paste(na.omit(df_genes_custom_geneset()$id), collapse = "\n")
  })
  output$custom_geneset_download <- downloadHandler(
    filename = function() { "Custom_geneset_gene_table.tsv" },
    content  = function(fname) {
      write.table(df_genes_custom_geneset(), fname, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )


  ## ---- Return reactive filter data ----------------------------------------
  list(
    df_outliers             = df_outliers,
    df_outliers_pathway     = df_outliers_pathway,
    df_genes_custom_geneset = df_genes_custom_geneset
  )
}
