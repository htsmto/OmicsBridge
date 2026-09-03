# =============================================================================
# DataOverview - MainPlot: Bar Plot Rendering
# File: modules/DataOverview/04_01_DataOverview_MainPlot_barplot.R
# Purpose: Renders a bar plot of the genes selected via the active filter mode
#          (Filtered genes / Pathway genes / Custom genesets), when the shared
#          "Show in a bar plot" switch is on. Bars use the scatter plot's
#          X-axis value (input$scat.x) for height, sorted descending, with a
#          diverging colour gradient (or a highlight colour for genes typed
#          into the "Find the genes of interest" textarea).
# Edit this file when: changing bar-plot aesthetics or which value/axis
#                       drives bar height and sort order.
# =============================================================================

mainplot_barplot_server <- function(input, output, session,
                                     df_outliers, df_outliers_pathway, df_genes_custom_geneset) {

  Gene_ex_barplot_status <- reactiveVal(NULL)
  output$Gene_ex_barplot_status <- renderText({ Gene_ex_barplot_status() })

  output$Gene_ex_barplot <- renderPlot({
    # Guard: axes must be selected
    if (length(input$scat.x) == 0 || is.null(input$scat.x) || input$scat.x == "None" ||
        length(input$scat.y) == 0 || is.null(input$scat.y) || input$scat.y == "None") {
      Gene_ex_barplot_status("Please select both X and Y axes to show the plot.")
      return(ggplot())
    }

    if (length(input$show_filterin_input_option) == 0 || is.null(input$show_filterin_input_option) ||
        input$show_filterin_input_option == "A") {
      Gene_ex_barplot_status("Please choose 'Filtered genes', 'Pathway genes', or 'Custom gene sets' and turn on 'Show in a bar plot'.")
      return(ggplot())
    }

    if (!isTRUE(input$show_outliers_bar_plot)) {
      Gene_ex_barplot_status("Turn on 'Show in a bar plot' to display this plot.")
      return(ggplot())
    }

    # Pick the source data frame based on the active filter mode
    outliers <- switch(input$show_filterin_input_option,
      "B" = df_outliers(),
      "C" = df_outliers_pathway(),
      "D" = df_genes_custom_geneset()
    )

    if (is.null(outliers) || length(outliers) == 0 || nrow(outliers) == 0) {
      Gene_ex_barplot_status("Nothing was detected. Please check the filter/pathway/geneset settings.")
      return(ggplot())
    }
    Gene_ex_barplot_status(NULL)

    # Sort descending by the X-axis value; freeze factor order for geom_bar
    outliers <- outliers[order(outliers[[input$scat.x]], decreasing = TRUE), ]
    outliers$id <- factor(outliers$id, levels = outliers$id)
    fill_option <- input$scat.x

    if (!is.null(input$target_gene) && input$target_gene != "") {
      highlight_category <- unlist(strsplit(input$target_gene, split = "\n"))
      outliers <- outliers %>%
        mutate(fill_colour = ifelse(id %in% highlight_category, input$interesting_gene_colour_id, "gray"))
      p <- ggplot(outliers, aes(x = id, y = .data[[input$scat.x]], fill = fill_colour)) +
        scale_fill_identity()
    } else {
      p <- ggplot(outliers, aes(x = id, y = .data[[input$scat.x]], fill = .data[[input$scat.x]]))
      values_for_colours <- outliers[[fill_option]][!is.na(outliers[[fill_option]])]
      if (min(values_for_colours) < 0) {
        if (max(values_for_colours) >= 0) {
          tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
          p <- p + scale_fill_gradientn(
            colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max),
            values = scales::rescale(c(-tmp, 0, tmp)), limits = c(-tmp, tmp), name = fill_option)
        } else {
          p <- p + scale_fill_gradientn(
            colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0), name = fill_option)
        }
      } else {
        p <- p + scale_fill_gradientn(
          colors = c(input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max),
          values = scales::rescale(c(0, max(values_for_colours))),
          limits = c(0, max(values_for_colours)), name = fill_option)
      }
    }

    if (isTRUE(input$show_outliers_rotate_x)) {
      p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
    }

    p <- p + geom_bar(stat = "identity") + labs(x = NULL)
    legend_key_size <- input$Gene_ex_barplot_legend_key_size

    p <- p +
      theme(legend.text = element_text(size = input$Gene_ex_barplot_legend_font_size),
            legend.title = element_text(size = input$Gene_ex_barplot_legend_font_size)) +
      guides(fill = guide_colourbar(barwidth = legend_key_size / 4, barheight = legend_key_size)) +
      theme(legend.margin = margin(-10, 0, 0, 0), legend.spacing.x = unit(0, "mm"), legend.spacing.y = unit(0, "mm")) +
      theme(axis.text.y = element_text(size = input$Gene_ex_barplot_ylab.font.size),
            axis.text.x = element_text(size = input$Gene_ex_barplot_xlab.font.size)) +
      theme(axis.title.y = element_text(size = input$Gene_ex_barplot_graph.title.font.size)) +
      theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05)) +
      theme(axis.ticks = element_line(linewidth = 0.1), axis.ticks.length = unit(0.5, "pt")) +
      theme(legend.key.height = unit(legend_key_size * 1.5, "mm"), legend.key.width = unit(legend_key_size / 2, "mm"),
            legend.spacing.x = unit(0.2, "mm"), legend.spacing.y = unit(0.2, "mm"))

    if (isTRUE(input$Gene_ex_barplot_white_background)) {
      p <- p + theme(panel.grid = element_blank(), panel.border = element_blank(),
                      axis.line = element_line(color = "black", linewidth = 0.1)) +
        theme(panel.background = element_rect(fill = "white", linewidth = 0)) +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    }
    if (input$Gene_ex_barplot_xlab.font.size == 0) {
      p <- p + theme(axis.text.x = element_blank(), axis.title.x = element_blank(),
                      axis.ticks.x = element_blank())
    }

    p
  }, width = reactive(input$Gene_ex_barplot_fig.width), height = reactive(input$Gene_ex_barplot_fig.height), res = 300)
}
