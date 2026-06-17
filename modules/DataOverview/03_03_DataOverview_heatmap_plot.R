# =============================================================================
# DataOverview - Heatmap: Plot
# File: modules/DataOverview/03_03_DataOverview_heatmap_plot.R
# Purpose: Renders the ggplot2 heatmap from the clustered expression matrix,
#          displays the expression table, provides cluster gene-name lookup,
#          and supplies a download handler for the standardised table.
# Edit this file when: changing colour scale, axis font sizes, legend
#                       formatting, or the expression table / download logic.
# =============================================================================

heatmap_plot_server <- function(input, output, session,
                                ex_datafreme_for_heatmap,
                                clustered_heatmap_ex) {

    ## plot
        output$Data_Overview_heatmap_plot <- renderPlot({
            if(!is.null(ex_datafreme_for_heatmap())){
                df_ex <- ex_datafreme_for_heatmap()
                gene_expression_matrix <- clustered_heatmap_ex()

                if(is.null(gene_expression_matrix)){
                    return(ggplot())
                }

                cols <- colnames(gene_expression_matrix)
                cols <- rev(cols[2:length(cols)])
                # cols <- cols[order(cols)]
                df_2 <- t(gene_expression_matrix[,cols]) # head(df_2)
                df5 <- data.frame(df_2)
                df5$sample <- rownames(df5)
                df_target_order <- rownames(gene_expression_matrix[order(gene_expression_matrix$Cluster),])
                df5 <- pivot_longer(data = df5, cols = -c(sample), names_to = "Genes", values_to = "value") # head(df5)
                df5$Genes <- factor(x = df5$Genes, levels = df_target_order, ordered = TRUE)
                df5$sample <- factor(x = df5$sample, levels =  cols, ordered = TRUE)
                p <- ggplot(data = df5, aes(x = Genes, y = sample)) + geom_tile(aes(fill = value)) +
                    scale_fill_gradient2(low=input$Data_Overview_heatmap_col_low, high=input$Data_Overview_heatmap_col_high,mid=input$Data_Overview_heatmap_col_mid, midpoint=0) +
                    theme(axis.text.y = element_text(size = input$Data_Overview_heatmap_ylab.font.size), axis.text.x = element_text(size = input$Data_Overview_heatmap_xlab.font.size))
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                if(input$Data_Overview_heatmap_xlab.font.size == 0){
                    p <- p + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
                }
                if(input$Data_Overview_heatmap_ylab.font.size == 0){
                    p <- p + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
                }
                p <- p + xlab('') + ylab('')
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_blank())
                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                p <- p + theme(legend.text = element_text(size = input$Data_Overview_heatmap_legend.size), legend.title = element_text(size = input$Data_Overview_heatmap_legend.size) )
                p <- p + theme(legend.key.size = unit(1.5, "mm"))
                p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                p
            }else{
                p <- ggplot()
                p
            }
        }, width=reactive(input$Data_Overview_heatmap_fig.width), height=reactive(input$Data_Overview_heatmap_fig.height), res=300)

    ##

    ## table
        # status
            Data_Overview_heatmap_expression_status <- reactiveVal(NULL)
            output$Data_Overview_heatmap_expression_status <- renderText({ Data_Overview_heatmap_expression_status() })
        #

        # show the table
            output$Data_Overview_heatmap_expression <- DT::renderDataTable({
              if(is.null(clustered_heatmap_ex())){
                Data_Overview_heatmap_expression_status('No heatmap is generated. Please check your input and click "Generate a heatmap".')
                data.frame()
              }else{
                Data_Overview_heatmap_expression_status(NULL)
                datatable(clustered_heatmap_ex(), options = list(scrollX = TRUE))
              }
            })

        #

        # Download the standardised table
            output$Data_Overview_heatmap_expression_download <- downloadHandler(
                filename = function(){"Heatmap_expression_tablle.tsv"},
                content = function(fname){ write.table(clustered_heatmap_ex(), fname, sep='\t', quote=F) }
            )
        #

        # select the cluster to show the gene names
            output$Data_Overview_heatmap_expression_cluster_select <- renderUI({
                if(is.null(clustered_heatmap_ex())){
                    return(NULL)
                }
                clusters <- sort(unique(clustered_heatmap_ex()$Cluster))
                selectInput(session$ns('Data_Overview_heatmap_expression_cluster_select'), 'Select the cluster number',  c('None'='None', clusters))
            })
        #

        # show the list of gene names
            output$Data_Overview_heatmap_expression_cluster_genename <- renderText({
                if(is.null(clustered_heatmap_ex())){
                    return(NULL)
                }
                if(length(input$Data_Overview_heatmap_expression_cluster_select) == 0 || input$Data_Overview_heatmap_expression_cluster_select == 'None'){
                    return(NULL)
                }
                ex_datafreme_for_heatmap_cluster <- clustered_heatmap_ex()[clustered_heatmap_ex()$Cluster == input$Data_Overview_heatmap_expression_cluster_select, ]
                paste(rownames(ex_datafreme_for_heatmap_cluster), collapse = "\n")
            })
        #

    ##
}
