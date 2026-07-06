# =============================================================================
# Clinical - Gene Correlation: Scatter Plot & Table
# File: modules/Clinical/04_clinical_GeneCorrelation_plot.R
# Purpose: Renders the correlation result table (with gene selector and download)
#          and the scatter / pairwise heatmap plot for selected gene pairs.
# Edit this file when: changing the plot type, colour scheme for the heatmap,
#                       scatter plot aesthetics, or the result table display.
# =============================================================================

gene_correlation_plot_server <- function(input, output, session,
                                          ex_table,
                                          Correlation_result_list,
                                          isCalculating,
                                          All_sample_flag,
                                          filtered_sample_ids) {
    ## show the result table
        # status
            Gene_correlation_table_status <- reactiveVal(NULL)
            output$Gene_correlation_table_status <- renderText({ Gene_correlation_table_status() })
        #

        # select the gene to show
            output$Gene_correlation_table_gene_select <- renderUI({
                if(length(Correlation_result_list()) > 0 && !is.null(Correlation_result_list())){
                    selectInput(session$ns("Gene_correlation_table_gene_select"), "Select a gene to show its correlation result table", c('None'='None', names(Correlation_result_list())))
                }else{
                    selectInput(session$ns("Gene_correlation_table_gene_select"), "Select a gene to show its correlation result table", c('None'='None'))
                }
            })
        #

        # show the table
            output$Gene_correlation_table <- DT::renderDataTable({
                if(isCalculating()){
                    return(NULL)
                }
                # when the calculation is not done yet
                if(length(Correlation_result_list()) == 0 || is.null(Correlation_result_list())){
                    Gene_correlation_table_status("Please set the inputs and calculate the correlation first.")
                    tmp <- data.frame('Gene'=character(0), 'r'=numeric(0), 'p'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'), rownames=FALSE))
                }

                # when the calculation is done but no gene is selected to show
                if(length(input$Gene_correlation_table_gene_select) == 0 || input$Gene_correlation_table_gene_select == 'None'){
                    Gene_correlation_table_status("Please select a gene to show its correlation result table.")
                    tmp <- data.frame('Gene'=character(0), 'r'=numeric(0), 'p'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'), rownames=FALSE))
                }

                # when the calculation is done and a gene is selected to show
                Gene_correlation_table_status(NULL)
                datatable(Correlation_result_list()[[input$Gene_correlation_table_gene_select]], options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'))

            })
        #

        # download the table
            output$Gene_correlation_table_download <- downloadHandler(
                filename = function(){"Gene_correlation_in_cohort.tsv"},
                content = function(fname){ write.table(Correlation_result_list()[[input$Gene_correlation_table_gene_select]], fname, sep='\t', row.names=F, quote=F) }
            )
        #


    ##

    ## show the correlation plot
        # status
            Gene_correlation_error_catch <- reactiveVal(NULL)
            output$Gene_correlation_error_catch <- renderText({ Gene_correlation_error_catch() })
        #

        # plot
            output$Gene_correlation_scatter_plot <- renderPlot({
                # when no dataset is loaded
                    if(length(ex_table())== 0 || is.null(ex_table())){
                        Gene_correlation_error_catch("Please select a dataset first.")
                        return(ggplot())
                    }

                # when correlation is not calculated
                    if(length(Correlation_result_list()) == 0 || is.null(Correlation_result_list())){
                        Gene_correlation_error_catch("Please set the inputs and calculate the correlation first.")
                        return(ggplot())
                    }

                # when no gene is selected, show a heatmap of the pairwise correlation
                    if(length(input$Gene_correlation_table_rows_selected) == 0 || input$Gene_correlation_table_gene_select == 'None' || input$Gene_correlation_table_gene_select == 'All_genes_correlation' || input$Gene_correlation_table_gene_select == 'All_genes_p_value'){
                        Gene_correlation_error_catch('The pairwise correlation heatmap of the input genes is shown. \nOnce you select a gene and its correlated gene in the table, a scatter plot will be shown here.')
                        cor_mat <- Correlation_result_list()[['All_genes_correlation']]
                        while(any(!is.finite(cor_mat))){
                            worst <- which.max(rowSums(!is.finite(cor_mat)))
                            cor_mat <- cor_mat[-worst, -worst, drop = FALSE]
                        }
                        if(nrow(cor_mat) < 2){
                            Gene_correlation_error_catch("Not enough genes with non-zero variance to compute a correlation heatmap. Please check the selected genes/samples.")
                            return(ggplot())
                        }
                        dist_rows <- as.dist(1 - cor_mat)
                        dist_cols <- as.dist(1 - t(cor_mat))
                        hc_rows <- hclust(dist_rows)
                        hc_cols <- hclust(dist_cols)
                        # Get dendrogram order
                        row_order <- hc_rows$order
                        col_order <- hc_cols$order
                        # Reorder correlation matrix
                        cor_mat_clustered <- cor_mat[row_order, col_order]
                        cor_df <- melt(cor_mat_clustered)
                        names(cor_df) <- c("Gene1", "Gene2", "Correlation")

                        # heatmap
                        p <- ggplot(cor_df, aes(x = Gene1, y = Gene2, fill = Correlation)) + geom_tile(color = NA)

                        # setting
                        p <- p + scale_fill_gradient2(low = input$Gene_correlation_pairwise_col_low, high = input$Gene_correlation_pairwise_col_high, mid=input$Gene_correlation_pairwise_col_mid, midpoint=0,  limits = c(-1,1), na.value = 'gray', name = "Correlation")
                        p <- p + theme(axis.text.x = element_text(angle = 45, hjust = 1, size=input$Gene_correlation_label_size), axis.text.y = element_text(size=input$Gene_correlation_label_size))
                        p <- p + labs(x = NULL, y = NULL)
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_blank())
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        if(input$Gene_correlation_label_size==0){
                            p <- p + theme(axis.text.x = element_blank(), axis.text.y = element_blank())
                         p <- p + theme(axis.ticks =element_blank())
                        }
                        p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                        p <- p + theme(legend.key.size = unit(2, "mm"))
                        p <- p + theme(legend.title =element_text(size=input$Gene_correlation_legend_size), legend.text = element_text(size=input$Gene_correlation_legend_size))
                        p
                    }else{
                        Gene_correlation_error_catch(NULL)
                        gene1 <- input$Gene_correlation_table_gene_select
                        gene2 <- Correlation_result_list()[[input$Gene_correlation_table_gene_select]][input$Gene_correlation_table_rows_selected, ]$Gene

                        # go to the expression data and generate a scatter plot
                        df_ex_for_correlation <- ex_table()[c(gene1, gene2), , drop=FALSE]
                        if(All_sample_flag() == FALSE && !is.null(filtered_sample_ids())){
                            df_ex_for_correlation <- df_ex_for_correlation[, colnames(df_ex_for_correlation) %in% filtered_sample_ids(), drop=FALSE]
                        }else{
                            df_ex_for_correlation <- df_ex_for_correlation
                        }
                        scatter_data <- data.frame(Gene1=unlist(df_ex_for_correlation[gene1, ]), Gene2=unlist(df_ex_for_correlation[gene2, ]), Sample=colnames(df_ex_for_correlation)) # head(scatter_data)
                        p <- ggplot(scatter_data, aes(x=Gene1, y=Gene2))
                        p <- p + geom_point(size=0.3, color=input$Gene_correlation_colour, alpha=0.7)
                        if(input$Gene_correlation_show_correlation_line){
                            p <- p + geom_smooth(method='lm', se=TRUE, color=input$Gene_correlation_colour, size=0.4)
                        }
                        p <- p + labs(x=gene1, y=gene2)
                        p <- p + theme(axis.text.y = element_text(size = input$Gene_correlation_label_size), axis.text.x = element_text(size = input$Gene_correlation_label_size))
                        p <- p + theme(axis.title.y = element_text(size = input$Gene_correlation_title_size), axis.title.x = element_text(size = input$Gene_correlation_title_size))
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))
                        p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        if(input$Gene_correlation_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", size=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p

                    }
            }, width=reactive(input$Gene_correlation_fig.width), height=reactive(input$Gene_correlation_fig.height), res=300)
        #
    ##
}
