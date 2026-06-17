# =============================================================================
# Clinical - Deconvolution: Plot & Table Rendering
# File: modules/Clinical/08_clinical_Deconvolution_plot.R
# Purpose: Renders the deconvolution heatmap, stacked barplot, gene-correlation
#          table, and gene-vs-cell-type scatter plot.
# Edit this file when: changing plot aesthetics, adding new visualisation
#                      types, or modifying how correlation results are displayed.
# =============================================================================

deconvolution_plot_server <- function(input, output, session, Gene_expression,
                                      deconv_table, deconv_long,
                                      isCalculating_deconv_long,
                                      Deconvolution_gene_correlation,
                                      isCalculating_Deconvolution_gene_correlation,
                                      All_sample_flag, filtered_sample_ids) {

    ## Heatmap/barplot plots
        # heatmap
            Deconvolution_Heatmap_status <- reactiveVal(NULL)
            output$Deconvolution_Heatmap_status <- renderText({Deconvolution_Heatmap_status()})

            output$Deconvolution_Heatmap_plot <- renderPlot({
                if(is.null(deconv_long())){
                    Deconvolution_Heatmap_status('Run the deconvolution first, and set the plot settings, then click \'Start Heatmap\'.')
                    return(ggplot())
                }else{
                    Deconvolution_Heatmap_status(NULL)
                    df_long <- deconv_long()

                    p <- ggplot(df_long, aes(x = CellType, y = Sample, fill = Score)) + geom_tile()
                    p <- p + scale_fill_gradient2(low = "blue", high = input$Deconvolution_Heatmap_high_colour, mid = input$Deconvolution_Heatmap_zero_colour, midpoint = 0,  name = "Deconvolution Score")
                    p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5))
                    p <- p + theme(axis.text.y = element_text(size = input$Deconvolution_Heatmap_Y_font.size), axis.text.x = element_text(size = input$Deconvolution_Heatmap_X_font.size))
                    p <- p + theme(axis.title = element_blank())
                    p <- p + theme(legend.key.height = unit(0.2, "cm"), legend.key.width  = unit(0.1, "cm"), legend.text = element_text(size = input$Deconvolution_Heatmap_legend_font.size), legend.title = element_text(size = input$Deconvolution_Heatmap_legend_font.size))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank())
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    if(input$Deconvolution_Heatmap_Y_font.size == 0){
                        p <- p + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
                    }
                    return(p)
                }
            }, width=reactive(input$Deconvolution_Heatmap_fig.width), height=reactive(input$Deconvolution_Heatmap_fig.height), res=300)
        #

        # barplot
            Deconvolution_Barplot_status <- reactiveVal(NULL)
            output$Deconvolution_Barplot_status <- renderText({Deconvolution_Barplot_status()})

            output$Deconvolution_Barplot_plot <- renderPlot({
                if(is.null(deconv_long())){
                    Deconvolution_Barplot_status('Run the deconvolution first, and set the plot settings, then click \'Start Barplot\'.')
                    return(ggplot())
                }else{
                    df_long <- deconv_long()
                    if(input$Deconvolution_Barplot_percentage){
                    df_long <- df_long %>%
                        group_by(Sample) %>%
                        mutate(prop = Score / sum(Score))
                    }
                    if(!input$Deconvolution_Barplot_percentage){
                        p <- ggplot(df_long, aes(x = Score, y = Sample, fill = CellType)) + geom_bar(stat = "identity")
                    }else{
                        p <- ggplot(df_long, aes(x = prop, y = Sample, fill = CellType)) + geom_bar(stat = "identity")
                    }
                    # p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5))
                    p <- p + theme(axis.title = element_blank())
                    p <- p + theme(axis.text.y = element_text(size = input$Deconvolution_Barplot_Y_font.size), axis.text.x = element_text(size = input$Deconvolution_Barplot_X_font.size))
                    p <- p + theme(legend.key.height = unit(0.2, "cm"), legend.key.width  = unit(0.1, "cm"), legend.text = element_text(size = input$Deconvolution_Barplot_legend_font.size), legend.title = element_text(size = input$Deconvolution_Barplot_legend_font.size))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank())
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    if(input$Deconvolution_Barplot_Y_font.size == 0){
                        p <- p + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
                    }
                    return(p)
                }
            }, width=reactive(input$Deconvolution_Barplot_fig.width), height=reactive(input$Deconvolution_Barplot_fig.height), res=300)
        #
    ##

    ## Correlation table and scatter plot
        # table show
            # status
                Deconvolution_Gene_correlation_status1 <- reactiveVal(NULL)
                output$Deconvolution_Gene_correlation_status1 <- renderText({ Deconvolution_Gene_correlation_status1() })
            #

            # table
                output$Deconvolution_Gene_correlation_table <- DT::renderDataTable({
                    if(isCalculating_Deconvolution_gene_correlation()){
                        Deconvolution_Gene_correlation_status1('Calculating, please wait...')
                        return(NULL)
                    }else if(is.null(Deconvolution_gene_correlation())){
                        Deconvolution_Gene_correlation_status1('The correlation table will be shown here.')
                        dataframe_tmp <- data.frame(Gene=character(), r=numeric(), p=numeric())
                        datatable(dataframe_tmp)
                    }else{
                        Deconvolution_Gene_correlation_status1(NULL)
                        datatable(Deconvolution_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
                    }
                })
            #
        #

        # Plot
            # status
                Deconvolution_Gene_correlation_status <- reactiveVal(NULL)
                output$Deconvolution_Gene_correlation_status <- renderText({ Deconvolution_Gene_correlation_status() })
            #

            # Plot
                output$Deconvolution_Gene_correlation_plot <- renderPlot({
                    # when deconvolution is not yet done
                        if(is.null(Deconvolution_gene_correlation())){
                            Deconvolution_Gene_correlation_status('Please calculate the correlation first, and then select a gene from the table to show the correlation plot.')
                            return(ggplot())
                        }
                    #

                    # when no gene is selected
                        if(length(input$Deconvolution_Gene_correlation_table_rows_selected)==0){
                            Deconvolution_Gene_correlation_status('Please select a gene from the table to show the correlation plot.')
                            return(ggplot())
                        }
                    #

                    # show a scatter plot
                        Deconvolution_Gene_correlation_status(NULL)
                        df_cor_out <- Deconvolution_gene_correlation()
                        cell_type <- df_cor_out$cell_type[1]
                        Gene2 <- df_cor_out[input$Deconvolution_Gene_correlation_table_rows_selected,]$Gene

                        df_geneEx <- Gene_expression()
                        deconv_table <- deconv_table() # deconv_table[1:3, 1:3]

                    # when filtering samples
                        if(All_sample_flag() == FALSE){
                            deconv_table <- deconv_table[, colnames(deconv_table) %in% filtered_sample_ids(), drop=FALSE]
                            df_geneEx <- df_geneEx[,colnames(df_geneEx) %in% filtered_sample_ids(), drop=FALSE]
                        }

                    # scatter plot
                        df_deconv_table_cell <- data.frame(deconv_table[cell_type,])
                        colnames(df_deconv_table_cell) <- 'cell_type' # head(df_deconv_table_cell)
                        df_deconv_table_cell$sample <- rownames(df_deconv_table_cell)
                        df_geneEx_selected <- data.frame(unlist(df_geneEx[Gene2, ])) # Gene2="CXCL10"
                        colnames(df_geneEx_selected) <- 'Gene2' # head(df_geneEx_selected )
                        df_geneEx_selected$sample <- rownames(df_geneEx_selected)
                        scatter_data <- merge(df_deconv_table_cell, df_geneEx_selected, by='sample') # head(scatter_data)
                        p <- ggplot(scatter_data, aes(x=Gene2, y=cell_type))
                        p <- p + geom_point(size=0.5, color=input$Deconvolution_Gene_correlation_colour, alpha=0.7)
                        if(input$Deconvolution_Gene_correlation_show_correlation_line){
                            p <- p + geom_smooth(method='lm', se=TRUE, color=input$Deconvolution_Gene_correlation_colour, size=0.4)
                        }
                        p <- p + labs(x=Gene2, y=cell_type)
                        p <- p + theme(axis.text = element_text(size = input$Deconvolution_Gene_correlation_label_size))
                        p <- p + theme(axis.title = element_text(size = input$Deconvolution_Gene_correlation_title_size))
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))
                        p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        if(input$Deconvolution_Gene_correlation_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", size=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p
                }, width=reactive(input$Deconvolution_Gene_correlation_fig.width), height=reactive(input$Deconvolution_Gene_correlation_fig.height),res=300)

            #

    ##

}
