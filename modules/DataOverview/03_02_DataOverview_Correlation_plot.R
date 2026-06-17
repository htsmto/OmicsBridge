# =============================================================================
# DataOverview - Correlation Analysis: Plot
# File: modules/DataOverview/03_02_DataOverview_Correlation_plot.R
# Purpose: Renders the pairwise correlation heatmap and the two-gene scatter
#          plot (with optional regression line) from the correlation results.
#          Also provides the result table and its download handler.
# Edit this file when: changing colour scale, scatter plot style, regression
#                       line, axis fonts, or legend formatting.
# =============================================================================

correlation_plot_server <- function(input, output, session,
                                    df_ex,
                                    Correlation_result_list,
                                    df_ex_for_correlation,
                                    isCalculating) {

    ## show the result table
        # status
            Two_gene_corr_table_status <- reactiveVal(NULL)
            output$Two_gene_corr_table_status <- renderText({ Two_gene_corr_table_status() })
        #

        # select the gene to show
            output$Two_gene_corr_table_gene_select <- renderUI({
                if(length(Correlation_result_list()) > 0 && !is.null(Correlation_result_list())){
                    selectInput(session$ns("Two_gene_corr_table_gene_select"), "Select a gene to show its correlation result table", c('None'='None', names(Correlation_result_list())))
                }else{
                    selectInput(session$ns("Two_gene_corr_table_gene_select"), "Select a gene to show its correlation result table", c('None'='None'))
                }
            })
        #

        # show the table
            output$Two_gene_corr_table <- DT::renderDataTable({
                if(isCalculating()){
                    return(NULL)
                }
                # when the calculation is not done yet
                if(length(Correlation_result_list()) == 0 || is.null(Correlation_result_list())){
                    Two_gene_corr_table_status("Please set the inputs and calculate the correlation first.")
                    tmp <- data.frame('Gene'=character(0), 'r'=numeric(0), 'p'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'), rownames=FALSE))
                }

                # when the calculation is done but no gene is selected to show
                if(length(input$Two_gene_corr_table_gene_select) == 0 || input$Two_gene_corr_table_gene_select == 'None'){
                    Two_gene_corr_table_status("Please select a gene to show its correlation result table.")
                    tmp <- data.frame('Gene'=character(0), 'r'=numeric(0), 'p'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'), rownames=FALSE))
                }

                # when the calculation is done and a gene is selected to show
                Two_gene_corr_table_status(NULL)
                datatable(Correlation_result_list()[[input$Two_gene_corr_table_gene_select]], options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'))

            })
        #

        # download the table
            output$Two_gene_corr_table_download <- downloadHandler(
                filename = function(){"Gene_correlations_in_count_data.tsv"},
                content = function(fname){ write.table(Correlation_result_list()[[input$Two_gene_corr_table_gene_select]], fname, sep='\t', row.names=F, quote=F) }
            )
        #


    ##

    ## show the correlation plot
        # status
            Two_gene_corr_corr_score <- reactiveVal(NULL)
            output$Two_gene_corr_corr_score <- renderText({ Two_gene_corr_corr_score() })

            # status for selecting samples
            Two_gene_corr_status_selectsample <- reactiveVal(NULL)
            output$Two_gene_corr_status_selectsample <- renderText({ Two_gene_corr_status_selectsample() })
            #
        #

        # plot
            output$Two_gene_corr_plot <- renderPlot({
                # when no dataset is loaded
                    if(length(df_ex())== 0 || is.null(df_ex())){
                        Two_gene_corr_corr_score("Please select a dataset first.")
                        return(ggplot())
                    }

                # when correlation is not calculated
                    if(length(Correlation_result_list()) == 0 || is.null(Correlation_result_list())){
                        Two_gene_corr_corr_score("Please set the inputs and calculate the correlation first.")
                        return(ggplot())
                    }

                # when no gene is selected, show a heatmap of the pairwise correlation
                    if(length(input$Two_gene_corr_table_rows_selected) == 0 || input$Two_gene_corr_table_gene_select == 'None' || input$Two_gene_corr_table_gene_select == 'All_genes_correlation' || input$Two_gene_corr_table_gene_select == 'All_genes_p_value'){
                        Two_gene_corr_corr_score('The pairwise correlation heatmap of the input genes is shown. \nOnce you select a gene and its correlated gene in the table, a scatter plot will be shown here.')
                        cor_mat <- Correlation_result_list()[['All_genes_correlation']]
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
                        p <- p + scale_fill_gradient2(low = input$Two_gene_corr_pairwise_col_low, high = input$Two_gene_corr_pairwise_col_high, mid=input$Two_gene_corr_pairwise_col_mid, midpoint=0,  limits = c(-1,1), na.value = 'gray', name = "Correlation")
                        p <- p + theme(axis.text.x = element_text(angle = 45, hjust = 1, size=input$Two_gene_corr_label.font.size), axis.text.y = element_text(size=input$Two_gene_corr_label.font.size))
                        p <- p + labs(x = NULL, y = NULL)
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_blank())
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        if(input$Two_gene_corr_label.font.size==0){
                            p <- p + theme(axis.text.x = element_blank(), axis.text.y = element_blank())
                         p <- p + theme(axis.ticks =element_blank())
                        }
                        p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                        p <- p + theme(legend.key.size = unit(2, "mm"))
                        p <- p + theme(legend.title =element_text(size=input$Two_gene_corr_legend.font.size), legend.text = element_text(size=input$Two_gene_corr_legend.font.size))
                        p
                    }else{
                        Two_gene_corr_corr_score(NULL)
                        gene1 <- input$Two_gene_corr_table_gene_select
                        gene2 <- Correlation_result_list()[[input$Two_gene_corr_table_gene_select]][input$Two_gene_corr_table_rows_selected, ]$Gene

                        # go to the expression data and generate a scatter plot
                        df_ex_for_correlation <- df_ex_for_correlation()[c(gene1, gene2), , drop=FALSE]

                        scatter_data <- data.frame(Gene1=unlist(df_ex_for_correlation[gene1, ]), Gene2=unlist(df_ex_for_correlation[gene2, ]), Sample=colnames(df_ex_for_correlation)) # head(scatter_data)
                        Group <- c()
                        for (i in strsplit(rownames(scatter_data), '_')){
                            tmp <- ''
                            for(j in 1:(length(i)-1)){
                                tmp <- paste0(tmp, i[j],'_')
                            }
                            tmp <- substr(tmp, 1, nchar(tmp)-1)
                            Group <- c(Group, tmp)
                        }
                        scatter_data <- data.frame(scatter_data)
                        scatter_data$Group <- Group
                        if(input$Two_gene_corr_plot_Use_single_colour){
                            p <- ggplot(scatter_data, aes(x=Gene1, y=Gene2))
                            p <- p + geom_point(size=0.3, color=input$Two_gene_corr_colour, alpha=0.7)
                        }else{
                            p <- ggplot(scatter_data, aes(x=Gene1, y=Gene2, color=Group))
                            p <- p + geom_point(size=0.3, alpha=0.7)
                        }

                        if(input$Two_gene_corr_plot_line){
                            p <- p + geom_smooth(method='lm', se=TRUE, color=input$Two_gene_corr_colour, size=0.4)
                        }
                        p <- p + theme(legend.title =element_blank(), legend.text = element_text(size=input$Two_gene_corr_legend.font.size))
                        p <- p + labs(x=gene1, y=gene2)
                        p <- p + theme(axis.text.y = element_text(size = input$Two_gene_corr_label.font.size), axis.text.x = element_text(size = input$Two_gene_corr_label.font.size))
                        p <- p + theme(axis.title.y = element_text(size = input$Two_gene_corr_title.font.size), axis.title.x = element_text(size = input$Two_gene_corr_title.font.size))
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))
                        p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        if(input$Two_gene_corr_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", size=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                        p <- p + theme(legend.key.size = unit(2, "mm"))
                        p

                    }
            }, width=reactive(input$Two_gene_corr_fig.width), height=reactive(input$Two_gene_corr_fig.height), res=300)
        #
    ##

}
