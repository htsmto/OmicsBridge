# =============================================================================
# Clinical - Survival Analysis: Plots and Table
# File: modules/Clinical/03_clinical_Survival_plot.R
# Purpose: Renders the result table (with download), the KM curve, and the
#          expression distribution histogram. All data comes from reactive
#          values passed in from the calculation sub-module.
# Edit this file when: changing KM plot style, distribution plot appearance,
#                      table columns, or download format.
# =============================================================================

survival_plot_server <- function(input, output, session, ex_table, isCalculating, df_Suv_p_and_HR, plot_lists) {

    ## show in a table
        # status
            Clinical_Survival_table_status <- reactiveVal(NULL)
            output$Clinical_Survival_table_status <- renderText({ Clinical_Survival_table_status() })
        #

        # table
            output$Clinical_Survival_table <- DT::renderDataTable({
                if(isCalculating() | is.null(df_Suv_p_and_HR())){
                    Clinical_Survival_table_status('The p-value and Hazard Ratio for each input gene will be shown in the table below after the calculation is done.)')
                    tmp <- data.frame('Gene'=character(0), 'P.value'=numeric(0), 'Hazard.Ratio'=numeric(0), stringsAsFactors = FALSE)
                    datatable(tmp, rownames = FALSE)
                }else{
                    Clinical_Survival_table_status(NULL)
                    datatable(df_Suv_p_and_HR()[, c('Gene', 'P.value', 'Hazard.Ratio')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
                }
            })

        #

        # download
          output$Clinical_Survival_table_download <- downloadHandler(
            filename = function(){"Survival_analysis.tsv"},
            content = function(fname){ write.table(df_Suv_p_and_HR(), fname, sep='\t', row.names=F, quote=F) }
          )
        #

    ##

    ## Plot
        # kaplan-meier plot
            # status
                Clinical_Survival_plot_error_catch <- reactiveVal(NULL)
                output$Clinical_Survival_plot_error_catch <- renderText({ Clinical_Survival_plot_error_catch() })
            #

            # plot
                output$Clinical_Survival_plot <- renderPlot({
                    # when calculating
                    if(length(isCalculating()) == 0 || isCalculating()){
                        return(ggplot())
                    }

                    # when there is no plot to show
                    if(is.null(plot_lists()) || length(plot_lists()) == 0){
                        Clinical_Survival_plot_error_catch('Please start the analysis first, and then select a gene from the table to show the corresponding plot.')
                        return(ggplot())
                    }

                    # when there is a plot but no gene is selected in the table,
                    if(length(input$Clinical_Survival_table_rows_selected) == 0 || is.null(input$Clinical_Survival_table_rows_selected)){
                        Clinical_Survival_plot_error_catch('Please select a gene from the table to show the corresponding plot.')
                        return(ggplot())
                    }

                    # when there is a plot and a gene is selected in the table, show the corresponding plot
                    selected_gene <- df_Suv_p_and_HR()[input$Clinical_Survival_table_rows_selected, 'Gene']
                    p <- plot_lists()[[selected_gene]]

                    if(length(p) == 0 || is.null(p)){
                        Clinical_Survival_plot_error_catch("The plot cannot be generated for the selected gene, potentially because the gene is not expressed in the dataset or cannot be divided into two groups with the selected split method due to its expression distribution.")
                        return(ggplot())
                    }

                    Clinical_Survival_plot_error_catch(NULL)
                    if(selected_gene == '(Custom grouping)'){
                        p <- p + scale_color_manual(values=c('group=Group1'=input$Clinical_Survival_High_colour, 'group=Group2'=input$Clinical_Survival_Low_colour), labels=c(paste0('Group 1 (n=', as.character(length(p$data$strata[p$data$strata=='group=Group1'])), ')'), paste0('Group 2 (n=', as.character(length(p$data$strata[p$data$strata=='group=Group2'])), ')'))) +
                            scale_fill_manual(values=c('group=Group1'=input$Clinical_Survival_High_colour, 'group=Group2'=input$Clinical_Survival_Low_colour), labels=c(paste0('Group 1 (n=', as.character(length(p$data$strata[p$data$strata=='group=Group1'])), ')'), paste0('Group 2 (n=', as.character(length(p$data$strata[p$data$strata=='group=Group2'])), ')')))
                    }else{
                        p <- p +
                            scale_color_manual(
                                values=c('group=High'=input$Clinical_Survival_High_colour, 'group=Low'=input$Clinical_Survival_Low_colour),
                                labels=c(paste0(selected_gene, '-High (n=', as.character(length(p$data$strata[p$data$strata=='group=High'])), ')'), paste0(selected_gene, '-Low (n=', as.character(length(p$data$strata[p$data$strata=='group=Low'])), ')'))
                                ) +
                            scale_fill_manual(
                                values=c('group=High'=input$Clinical_Survival_High_colour, 'group=Low'=input$Clinical_Survival_Low_colour),
                                labels=c(paste0(selected_gene, '-High (n=', as.character(length(p$data$strata[p$data$strata=='group=High'])), ')'), paste0(selected_gene, '-Low (n=', as.character(length(p$data$strata[p$data$strata=='group=Low'])), ')'))
                                )
                    }
                    p <- p + guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Clinical_Survival_legend_size))
                    p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                    p <- p + theme(axis.text.y = element_text(size = input$Clinical_Survival_label_size), axis.text.x = element_text(size = input$Clinical_Survival_label_size))
                    p <- p + theme(axis.title.y = element_text(size = input$Clinical_Survival_title_size), axis.title.x = element_text(size = input$Clinical_Survival_title_size))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p <- p + theme(legend.key.size = unit(2, "mm"))
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    p <- p + labs(title=NULL)
                    p


                }, width=reactive(input$Clinical_Survival_fig.width), height=reactive(input$Clinical_Survival_fig.height), res=300)
            #

        #

        # Expression distribution
            # status
                Clinical_Survival_plot_distribution_status <- reactiveVal(NULL)
                output$Clinical_Survival_plot_distribution_status <- renderText({ Clinical_Survival_plot_distribution_status() })
            #

            # plot
                output$Clinical_Survival_distribution_plot <- renderPlot({
                    # when calculating
                    if(length(isCalculating()) == 0 || isCalculating()){
                        return(ggplot())
                    }

                    # when there is no plot to show
                    if(length(plot_lists()) == 0 || is.null(plot_lists())){
                        Clinical_Survival_plot_error_catch('Please start the analysis first, and then select a gene from the table to show the corresponding plot.')
                        return(ggplot())
                    }

                    # when there is a plot but no gene is selected in the table,
                    if(length(input$Clinical_Survival_table_rows_selected) == 0 || is.null(input$Clinical_Survival_table_rows_selected)){
                        Clinical_Survival_plot_error_catch('Please select a gene from the table to show the corresponding plot.')
                        return(ggplot())
                    }

                    # when there is a plot and a gene is selected in the table
                    gene_histgram <- df_Suv_p_and_HR()[input$Clinical_Survival_table_rows_selected, 'Gene']

                    # check if the gene is in the table
                    if(!(gene_histgram %in% rownames(ex_table()))){
                        Clinical_Survival_plot_distribution_status("The expression distribution plot cannot be generated for the selected gene, potentially because the gene is not expressed in the dataset.")
                        return(ggplot())
                    }
                    df_geneEx <- ex_table()[gene_histgram,]
                    df_geneEx_t <- data.frame(t(df_geneEx))
                    p <- ggplot(df_geneEx_t, aes(x=.data[[gene_histgram]]))
                    p <- p + geom_histogram(fill=input$Clinical_Survival_distribution_colour, alpha=0.6, bins=input$Clinical_Survival_distribution_bin_num)
                    p <- p + ggtitle(gene_histgram)
                    p <- p + xlab('Expression')
                    p <- p + theme(axis.text = element_text(size = input$Clinical_Survival_distribution_label_size))
                    p <- p + theme(axis.title = element_text(size = input$Clinical_Survival_distribution_title_size))
                    p <- p + theme(plot.title = element_text(size = input$Clinical_Survival_distribution_graphtitle_size))
                    p <- p + theme(legend.margin = margin(-5, 0, 0, 0))
                    p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    if(input$Clinical_Survival_distribution_white_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p

                },width=reactive(input$Clinical_Survival_distribution_fig.width), height=reactive(input$Clinical_Survival_distribution_fig.height),res=300)

            #

        #

    ##
}
