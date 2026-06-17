# =============================================================================
# Clinical - Expression Comparison: Plot & Table Rendering
# File: modules/Clinical/06_clinical_ExpressionCompare_plot.R
# Purpose: Renders the statistical test result table, download handler, and
#          the box/violin/swarm plot for the selected gene.
# Edit this file when: changing the statistical plot type, plot aesthetics,
#                       colour palette options, or the result table download.
# =============================================================================

expr_compare_plot_server <- function(input, output, session,
                                     isCalculating,
                                     Expression_compare_test_result_table,
                                     Expression_compare_pivot_table_for_plot) {
    ## Test result table
        # status
            Expression_subtype_table_status <- reactiveVal(NULL)
            output$Expression_subtype_table_status <- renderText({ Expression_subtype_table_status() })
        #

        # table
            output$Expression_subtype_table <- renderDataTable({
                if(isCalculating() == TRUE){
                    Expression_subtype_table_status('Calculating... Please wait.')
                    return(NULL)
                } else if(is.null(Expression_compare_test_result_table()) || length(Expression_compare_test_result_table()) == 0){
                    Expression_subtype_table_status('No test result to show. Please click the "Start comparing" button to perform the test first.')
                    datatable(data.frame('Gene'=character(0), 'Statistic'=numeric(0), 'P.value'=numeric(0), stringsAsFactors = FALSE) , selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                } else {
                    Expression_subtype_table_status(NULL)
                    datatable(Expression_compare_test_result_table(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                }
            })
        #

        # download the table
            output$Expression_subtype_table_download <- downloadHandler(
            filename = function(){"Expression_across_subtype.tsv"},
            content = function(fname){ write.table(Expression_compare_test_result_table(), fname, sep='\t', row.names=F, quote=F) }
            )
        #

    ##

    ## Plot
        # status
            Expression_subtype_note <- reactiveVal(NULL)
            output$Expression_subtype_note <- renderText({ Expression_subtype_note() })
        #

        # plot
            output$Expression_subtype_plot <- renderPlot({
                if(isCalculating() == TRUE){
                    Expression_subtype_note('Calculating... Please wait.')
                    return(ggplot())
                }


                # No test results
                    if(length(Expression_compare_test_result_table()) == 0 || is.null(Expression_compare_test_result_table())){
                        Expression_subtype_note('No test result to show. Please click the "Start comparing" button to perform the test first.')
                        return(ggplot())
                    }
                #

                # test results but no row is selected
                    if(length(input$Expression_subtype_table_rows_selected) == 0){
                        Expression_subtype_note('Please select a gene (row) from the test result table to show the plot.')
                        return(ggplot())
                    }
                #

                # make a plot
                    df_out <- Expression_compare_pivot_table_for_plot()
                    gene <- Expression_compare_test_result_table()[input$Expression_subtype_table_rows_selected,]$Gene
                    df_out_tmp <- df_out[df_out$Genes == gene,] # head(df_out_tmp)
                    number_each_group <- 'The number of data in each subtypes. \n'
                    for (nm in names(table(df_out_tmp[,colnames(df_out_tmp)[2]]))){
                        number_each_group <- paste0(number_each_group, nm , ': ', table(df_out_tmp[,colnames(df_out_tmp)[2]])[nm], '\n') # df_out[,])
                    }
                    # show the gene name and the number of samples in each subtype in the plot note
                    group_by <- colnames(df_out_tmp)[2]
                    message <- paste0(
                        "Gene: ", gene, "\n",
                        number_each_group
                    )
                    Expression_subtype_note(message)
                    if(input$Expression_subtype_use_single_colour){
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=Expression))
                    }else{
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=Expression, fill=.data[[group_by]]))
                    }
                    if(input$Expression_subtype_figtype == 'A'){  # boxplot
                        if(input$Expression_subtype_use_single_colour){
                            if(length(input$Expression_subtype_choose_single_colour) != 0){
                                p <- p + geom_boxplot(fill=input$Expression_subtype_choose_single_colour, size=0.2, outlier.size=0.5)
                            }
                        }else{
                            p <- p + geom_boxplot(color='black', size=0.2, outlier.size=0.5)
                            if(length(input$Expression_subtype_select_colour_pallete) == 0 || input$Expression_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Expression_subtype_figtype == 'B'){ # violin plot
                        if(input$Expression_subtype_use_single_colour){
                            if(length(input$Expression_subtype_choose_single_colour) != 0){
                                p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour, size=0.2)
                            }
                        }else{
                            p <- p + geom_violin(color='black',trim = FALSE, size=0.2)
                            if(length(input$Expression_subtype_select_colour_pallete) == 0 ||   input$Expression_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Expression_subtype_figtype == 'C'){ # swarm plot
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=Expression, color=.data[[group_by]]))
                        if(input$Expression_subtype_use_single_colour){
                            if(length(input$Expression_subtype_choose_single_colour) != 0){
                                p <- p + geom_beeswarm(size=input$Expression_subtype_dot.size,color=input$Expression_subtype_choose_single_colour)
                            }
                        }else{
                            p <- p + geom_beeswarm(size=input$Expression_subtype_dot.size)
                            if(length(input$Expression_subtype_select_colour_pallete) == 0 || input$Expression_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_color_viridis_d(option=input$Expression_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Expression_subtype_figtype == 'D'){ # swarm plot + violin plot
                        if(input$Expression_subtype_use_single_colour){
                            if(length(input$Expression_subtype_choose_single_colour) != 0){
                                p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour, size=0.2)
                            }
                        }else{
                            p <- p + geom_violin(trim = FALSE, size=0.2)
                            if(length(input$Expression_subtype_select_colour_pallete) == 0 || input$Expression_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
                            }
                        }
                        p <- p + geom_jitter(width=0.1, height=0, size=input$Expression_subtype_dot.size)
                    }
                    if(input$Expression_subtype_rotate_x){
                        p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                    }
                    p <- p + theme(axis.text.y = element_text(size = input$Expression_subtype_XY_label.font.size), axis.text.x = element_text(size = input$Expression_subtype_XY_label.font.size))
                    p <- p + theme(axis.title.y = element_text(size = input$Expression_subtype_XY_title.font.size), axis.title.x = element_text(size = input$Expression_subtype_XY_title.font.size))
                    p <- p + theme(legend.position = 'none')
                    p <- p + ggtitle(gene) + theme(plot.title = element_text(size = input$Expression_subtype_title.font.size))
                    p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))
                    p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    if(input$Expression_subtype_white_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", size=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    output$Expression_subtype_error_catch <- renderText({NULL})
                    p



            }, width=reactive(input$Expression_subtype_fig.width), height=reactive(input$Expression_subtype_fig.height), res=300)

        #


        # UI
            output$Expression_subtype_choose_single_colour_ui <- renderUI({
                if(length(input$Expression_subtype_use_single_colour) == 0 || input$Expression_subtype_use_single_colour == FALSE){
                    return(NULL)
                } else {
                    colourpicker::colourInput(session$ns('Expression_subtype_choose_single_colour'), 'Choose a colour', value='#000000')
                }
            })

        #
    ##
}
