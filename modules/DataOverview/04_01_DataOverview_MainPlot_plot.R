# =============================================================================
# DataOverview - MainPlot: Scatter Plot Rendering
# File: modules/DataOverview/04_01_DataOverview_MainPlot_plot.R
# Purpose: Renders the interactive ggplot2 scatter plot.
#          Receives reactive gene lists and filtered data frames from the
#          gene_input and filter sub-servers, and applies:
#            - Manual gene highlights (Input 1 / Input 2) with custom colours
#            - Threshold / pathway / custom-geneset highlights with sign colouring
#            - Brush-selection labels
#            - Plot appearance options (axes, point size, background, limits)
# Edit this file when: changing plot aesthetics, adding new layers
#                       (e.g. density contours, reference lines), or
#                       modifying gene label behaviour.
# =============================================================================

mainplot_plot_server <- function(input, output, session, df_ex,
                                 Interesting_gene, Interesting_gene2,
                                 df_outliers, df_outliers_pathway,
                                 df_genes_custom_geneset) {

  # --- [1] Helper: highlight manually entered genes -------------------------
  # Adds coloured points and optional text/label repel for Inputs 1 and 2.
  # Genes from Input 1 take priority over Input 2 when both overlap.
  add_highlights_combined <- function(df, p, genes1, genes2) {
    all_genes <- unique(c(genes1, genes2))
    if (length(all_genes) == 0) return(p)

    df_sub <- df[df$id %in% all_genes, ]
    # Assign type: 'g1' for Input 1 genes, 'g2' for Input 2 only
    df_sub$gene_type <- ifelse(df_sub$id %in% genes1, "g1", "g2")

    p <- p + geom_point(data = df_sub, aes(color = gene_type), size = input$high.pt.size)

    if (input$show_label) {
      label_geom <- if (input$main_plot_white_back_label) geom_label_repel else geom_text_repel
      p <- p + label_geom(data = df_sub, aes(label = id, color = gene_type),
                          size = input$high.label.size,
                          max.overlaps = input$label.overlap.level,
                          segment.size = 0.2)
    }
    p <- p + scale_color_manual(
      values = c(g1 = input$interesting_gene_colour_id,
                 g2 = input$main_plot_target_genes_2_colour),
      guide = "none")
    return(p)
  }


  # --- [2] Helper: highlight filtered genes with sign-based colouring --------
  # Used for threshold (B), pathway (C), and custom-geneset (D) modes.
  # Genes with X >= 0 get colour_pos; genes with X < 0 get colour_neg.
  # Optionally draws vertical/horizontal threshold lines.
  highlight_filtered_genes <- function(df, p, filtered_df, filter_flag,
                                       X_type, Y_type, X1, X2, Y1, Y2,
                                       colour_pos, colour_neg) {
    if (length(filtered_df) == 0 || is.null(filtered_df)) return(p)

    filtered_df$sign_group <- ifelse(filtered_df[[input$scat.x]] >= 0, "pos", "neg")
    p <- p + geom_point(data = filtered_df, aes(color = sign_group), size = input$high.pt.size)

    if (input$show_gene_label) {
      label_geom <- if (input$main_plot_white_back_label) geom_label_repel else geom_text_repel
      p <- p + label_geom(data = filtered_df, aes(label = id, color = sign_group),
                          size = input$high.label.size,
                          max.overlaps = input$label.overlap.level,
                          segment.size = 0.2)
    }

    # Draw threshold reference lines when the "show lines" toggle is on
    if (filter_flag) {
      switch(X_type,
        "B" = { p <- p + geom_vline(xintercept = X1, linetype = "dotted", linewidth = 0.2) },
        "C" = { p <- p + geom_vline(xintercept = X2, linetype = "dotted", linewidth = 0.2) },
        "D" = { p <- p + geom_vline(xintercept = X1, linetype = "dotted", linewidth = 0.2) +
                         geom_vline(xintercept = X2, linetype = "dotted", linewidth = 0.2) },
        "E" = { p <- p + geom_vline(xintercept = X1, linetype = "dotted", linewidth = 0.2) +
                         geom_vline(xintercept = X2, linetype = "dotted", linewidth = 0.2) }
      )
      switch(Y_type,
        "B" = { p <- p + geom_hline(yintercept = Y1, linetype = "dotted", linewidth = 0.2) },
        "C" = { p <- p + geom_hline(yintercept = Y2, linetype = "dotted", linewidth = 0.2) },
        "D" = { p <- p + geom_hline(yintercept = Y1, linetype = "dotted", linewidth = 0.2) +
                         geom_hline(yintercept = Y2, linetype = "dotted", linewidth = 0.2) },
        "E" = { p <- p + geom_hline(yintercept = Y1, linetype = "dotted", linewidth = 0.2) +
                         geom_hline(yintercept = Y2, linetype = "dotted", linewidth = 0.2) }
      )
    }

    p <- p + scale_color_manual(values = c("pos" = colour_pos, "neg" = colour_neg), guide = "none")
    return(p)
  }


  # --- [3] Main scatter plot render ------------------------------------------
  # Assembles the full ggplot by layering all highlight groups on top of the
  # base scatter. Plot dimensions respond to numeric inputs from the UI.

  Gene_ex_status <- reactiveVal(NULL)
  output$Gene_ex_status <- renderText({ Gene_ex_status() })

  output$Gene_ex <- renderPlot({
    # Guard: data must be loaded and axes selected
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      Gene_ex_status("The data is not loaded. Please check the data and try again.")
      return(ggplot())
    }
    if (length(input$scat.y) == 0 || input$scat.y == "None" ||
        length(input$scat.x) == 0 || input$scat.x == "None") {
      Gene_ex_status("Please select both X and Y axes to show the plot.")
      return(ggplot())
    }
    Gene_ex_status(NULL)
    df_main_plot <- df_ex()

    # Base scatter layer
    p <- ggplot(df_main_plot, aes(x = .data[[input$scat.x]], y = .data[[input$scat.y]])) +
         geom_point(size = input$pt.size)

    # Manually highlighted genes (Input 1 + Input 2)
    p <- add_highlights_combined(df_main_plot, p, Interesting_gene(), Interesting_gene2())

    # Brush-selection labels (capped at 500 to avoid text clutter)
    tryCatch({
      res <- brushedPoints(df_main_plot, input$plot_brush,
                           xvar = input$scat.x, yvar = input$scat.y)
      if (nrow(res) < 500) {
        label_geom <- if (input$main_plot_white_back_label) geom_label_repel else geom_text_repel
        p <- p + label_geom(data = res, color = "black", aes(label = id),
                            size = input$high.label.size,
                            max.overlaps = input$label.overlap.level,
                            segment.size = 0.2)
      }
    }, error = function(e) NULL)

    # Filtered gene highlights — which set depends on the active filter mode
    if (input$show_filterin_input_option == "B") {
      if (input$How_to_filter == "B") {
        p <- highlight_filtered_genes(df_main_plot, p, df_outliers(),
          input$show_threhold_lines,
          input$Main_scatter_thr_X_method, input$Main_scatter_thr_Y_method,
          input$Main_scatter_thr_X1, input$Main_scatter_thr_X2,
          input$Main_scatter_thr_Y1, input$Main_scatter_thr_Y2,
          input$outlier_gene_colour_id, input$outlier_gene_colour_id_negative)
      } else {
        p <- highlight_filtered_genes(df_main_plot, p, df_outliers(), FALSE,
          "A", "A", 0, 0, 0, 0,
          input$outlier_gene_colour_id, input$outlier_gene_colour_id_negative)
      }
    } else if (input$show_filterin_input_option == "C") {
      p <- highlight_filtered_genes(df_main_plot, p, df_outliers_pathway(),
        input$show_threhold_lines_pathway,
        input$Main_scatter_pathway_thr_X_method, input$Main_scatter_pathway_thr_Y_method,
        input$Main_scatter_pathway_thr_X1, input$Main_scatter_pathway_thr_X2,
        input$Main_scatter_pathway_thr_Y1, input$Main_scatter_pathway_thr_Y2,
        input$outlier_gene_colour_id, input$outlier_gene_colour_id_negative)
    } else if (input$show_filterin_input_option == "D") {
      p <- highlight_filtered_genes(df_main_plot, p, df_genes_custom_geneset(),
        input$show_threhold_lines_geneset,
        input$Main_scatter_geneset_thr_X_method, input$Main_scatter_geneset_thr_Y_method,
        input$Main_scatter_geneset_thr_X1, input$Main_scatter_geneset_thr_X2,
        input$Main_scatter_geneset_thr_Y1, input$Main_scatter_geneset_thr_Y2,
        input$outlier_gene_colour_id, input$outlier_gene_colour_id_negative)
    }

    # Plot appearance: fonts, grid, background, axis limits
    p <- p +
      theme(axis.text.y  = element_text(size = input$label.font.size),
            axis.text.x  = element_text(size = input$label.font.size),
            axis.title.y = element_text(size = input$title.font.size),
            axis.title.x = element_text(size = input$title.font.size),
            panel.grid.major = element_line(linewidth = 0.1),
            panel.grid.minor = element_line(linewidth = 0.05),
            axis.ticks        = element_line(linewidth = 0.1),
            axis.ticks.length = unit(0.5, "pt"))

    if (input$while_background) {
      p <- p + theme(
        panel.grid        = element_blank(),
        panel.border      = element_blank(),
        axis.line         = element_line(color = "black", linewidth = 0.1),
        panel.background  = element_rect(fill = "white", linewidth = 0),
        panel.grid.major  = element_blank(),
        panel.grid.minor  = element_blank())
    }

    # Apply user-defined axis limits (NA = auto-scale)
    xlim1 <- ifelse(is.numeric(input$main_plot_xlim_1), input$main_plot_xlim_1, NA)
    xlim2 <- ifelse(is.numeric(input$main_plot_xlim_2), input$main_plot_xlim_2, NA)
    ylim1 <- ifelse(is.numeric(input$main_plot_ylim_1), input$main_plot_ylim_1, NA)
    ylim2 <- ifelse(is.numeric(input$main_plot_ylim_2), input$main_plot_ylim_2, NA)
    p + coord_cartesian(xlim = c(xlim1, xlim2), ylim = c(ylim1, ylim2))

  }, width = reactive(input$fig.width), height = reactive(input$fig.height), res = 300)
}
