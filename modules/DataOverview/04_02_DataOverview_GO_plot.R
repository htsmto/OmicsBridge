# =============================================================================
# DataOverview - GO / Pathway Enrichment: Plot
# File: modules/DataOverview/04_02_DataOverview_GO_plot.R
# Purpose: Renders the bar plot, bubble plot, and network plot from GO/KEGG
#          enrichment results produced by go_calc_server().
# Edit this file when: changing plot style, colour gradients, category count,
#                       or layout of any of the three visualisation panels.
# =============================================================================

go_plot_server <- function(input, output, session, goResult, isCalculating) {

    ## Show the result
        # Bar plot
            # status
                GO_goPlot_status <- reactiveVal(NULL)
                output$GO_goPlot_status <- renderText({ GO_goPlot_status() })
            #

            # show the bar plot
                output$GO_goPlot <- renderPlot({
                    if (isCalculating()) {
                        return(ggplot())
                    }else{
                        if(length(goResult()) == 0 || is.null(goResult())){
                            GO_goPlot_status("A Bar plot of the GO/KEGG analysis results will be shown here.")
                            return(ggplot())

                        }else{
                            GO_goPlot_status(NULL)

                            # use ggplot, not enrichplot:barplot
                            df_goResults <- as.data.frame(goResult())
                            showCategory <- input$GO_fig.category_show_number
                            df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                            df_goResults$Description <- stringr::str_wrap(df_goResults$Description, width=50)

                            # Create barplot with custom colors
                            p <- ggplot(df_goResults, aes(x = Count, y = reorder(Description, Count), fill = p.adjust)) + geom_bar(stat = "identity") + labs(x = "Count", y = NULL, fill = "P.adjust")
                            p <- p + theme(axis.text.y = element_text(size = input$GO_ylab.font.size), axis.text.x = element_text(size = input$GO_xlab.font.size), axis.title.x = element_text(size=input$GO_xtitle.font.size))
                            p <- p + theme(legend.text = element_text(size = input$GO_legend.size), legend.title = element_text(size = input$GO_legend.size) )
                            p <- p + theme(legend.key.size = unit(1.5, "mm"))
                            p <- p + scale_fill_gradient(low = input$GO_bar_colour_min, high = input$GO_bar_colour_max)
                            p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                            p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
                            # white background
                            if(input$GO_bar_white_background){
                                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                            }
                            return(p)
                        }
                    }
                }, width=reactive(input$GO_fig.width), height=reactive(input$GO_fig.height), res=300)

            #
        #

        # Bubble plot
            # status
                GO_goBubblePlot_status <- reactiveVal(NULL)
                output$GO_goBubblePlot_status <- renderText({ GO_goBubblePlot_status() })
            #

            # show the bubble plot
                output$GO_goBubblePlot <- renderPlot({
                    if (isCalculating()) {
                        return(ggplot())
                    }else{
                        if(length(goResult()) == 0 || is.null(goResult())){
                            GO_goBubblePlot_status("A Bubble plot of the GO/KEGG analysis results will be shown here.")
                            return(ggplot())
                        }
                        else{
                            GO_goBubblePlot_status(NULL)
                            df_goResults <- as.data.frame(goResult())
                            showCategory <- input$GO_Bubble_fig.category_show_number
                            df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                            df_goResults$GeneRatio <- sapply(df_goResults$GeneRatio, function(x) {
                                parts <- strsplit(x, "/")[[1]]
                                as.numeric(parts[1]) / as.numeric(parts[2])
                            })
                            df_goResults$Description <- stringr::str_wrap(df_goResults$Description, width=50)

                            p <- ggplot(df_goResults, aes(x = GeneRatio, y = reorder(Description, Count), size =Count , color = p.adjust)) + geom_point() +  labs(x = "GeneRatio", y = NULL, color = "P.adjust", size = "Count")
                            p <- p + theme(axis.text.y = element_text(size = input$GO_Bubble_ylab.font.size), axis.text.x = element_text(size = input$GO_Bubble_xlab.font.size), axis.title.x = element_text(size=input$GO_Bubble_xtitle.font.size))
                            p <- p + theme(legend.text = element_text(size = input$GO_Bubble_legend.size), legend.title = element_text(size = input$GO_Bubble_legend.size) )
                            p <- p + theme(legend.key.size = unit(1.5, "mm"))
                            p <- p + scale_color_gradient(low = input$GO_Bubble_colour_min, high = input$GO_Bubble_colour_max)
                            p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                            p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
                            # white background
                            if(input$GO_Bubble_white_background){
                                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                            }
                            p
                        }
                    }
                }, width=reactive(input$GO_Bubble_fig.width), height=reactive(input$GO_Bubble_fig.height), res=300)
            #
        #

        # network plot
            # status
                GO_netPlot_status_status <- reactiveVal(NULL)
                output$GO_netPlot_status <- renderText({ GO_netPlot_status_status() })
            #

            # show the plot
                output$GO_netPlot <- renderPlot({
                    if (isCalculating()) {
                        return(ggplot())
                    }else{
                        if(length(goResult()) == 0 || is.null(goResult())){
                            GO_netPlot_status_status("A network plot of the top 5 terms from the GO/KEGG analysis results will be shown here.")
                            return(ggplot())
                        }
                        else{
                            GO_netPlot_status_status(NULL)
                            df_goResults <- as.data.frame(goResult())
                            showCategory <- input$GO_netPlot_category_show_number
                            df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                            gene_list <- strsplit(df_goResults$geneID, "/")  # Split gene lists
                            edge_df <- data.frame(
                                GO_Term = rep(df_goResults$Description, sapply(gene_list, length)),  # Repeat GO terms correctly
                                Gene = unlist(gene_list)  # Flatten list into a single column
                            )
                            df_goResults$Description <- stringr::str_wrap(df_goResults$Description, width=50)

                            # Generate igraph object
                            graph <- igraph::graph_from_data_frame(edge_df, directed = FALSE)
                            node_type <- ifelse(igraph::V(graph)$name %in% df_goResults$Description, "GO Term", "Gene")
                            igraph::E(graph)$GO_Term <- edge_df$GO_Term  # Assign GO term category to edges
                            node_size <- ifelse(igraph::V(graph)$name %in% df_goResults$Description, input$GO_netPlot_node_size_term, input$GO_netPlot_node_size_gene)  # GO terms larger than genes

                            if(input$GO_netPlot_circle_plot){
                                p <- ggraph(graph, layout = "circle")
                            }else{
                                p <- ggraph(graph, layout = "fr")  # Fruchterman-Reingold layout
                            }
                            if(input$GO_netPlot_change_edge_colour){
                                p <- p + geom_edge_link(aes(color = GO_Term), alpha = 0.6, linewidth = input$GO_netPlot_edge_size_term)
                            }else{
                                p <- p + geom_edge_link(alpha = 0.6, linewidth = input$GO_netPlot_edge_size_term)
                            }
                            p <- p + scale_edge_color_manual(values = setNames(rainbow(length(unique(edge_df$GO_Term))), unique(edge_df$GO_Term)))
                            p <- p + geom_node_point(aes(size = node_size, color = node_type))
                            p <- p + scale_color_manual(values = c("GO Term" = input$GO_netPlot_node_colour_term, "Gene" = input$GO_netPlot_node_colour_gene))
                            p <- p + scale_size_continuous(range = c(input$GO_netPlot_node_size_gene, input$GO_netPlot_node_size_term))
                            if(input$GO_netPlot_label_size_term_term > 0){
                                p <- p + ggraph::geom_node_text(
                                data = function(x) dplyr::filter(x, node_type == "GO Term"),
                                aes(label = name), color = input$GO_netPlot_node_colour_term, size = input$GO_netPlot_label_size_term_term,
                                repel = TRUE, max.overlaps = Inf, segment.size = 0.2
                                )
                            }
                            if(input$GO_netPlot_label_size_term_gene > 0){
                                p <- p + ggraph::geom_node_text(
                                data = function(x) dplyr::filter(x, node_type == "Gene"),
                                aes(label = name), color = input$GO_netPlot_node_colour_gene, size = input$GO_netPlot_label_size_term_gene,
                                repel = TRUE, segment.size = 0.2, max.overlaps = 5
                                )
                            }
                            p <- p + guides(color = "none")
                            p <- p + theme(legend.key.size = unit(0.5, "mm"))
                            p <- p + theme(legend.text = element_text(size = input$GO_netPlot_legend.size), legend.title = element_text(size = input$GO_netPlot_legend.size) )
                            p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                            p
                        }
                    }
                }, width=reactive(input$GO_netPlot_fig.width), height=reactive(input$GO_netPlot_fig.height), res=300)
            #
        #
    ##
}
