# =============================================================================
# DatasetsCompare - Single Gene Comparison: Plot
# File: modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_plot.R
# Purpose: Renders the cross-dataset gene comparison plot (scatter or bar),
#          including colour scale logic, data table display, and download.
# Edit this file when: changing the plot type, adding statistical tests
#                       between datasets, or modifying colour coding.
# =============================================================================

compare_one_gene_plot_server <- function(input, output, session, used_genes, all_comapring_tables, Y_axis_name, colour_name) {

    ## Data information table
        # status
            dataframe_comparing_dataset_status <- reactiveVal(NULL)
            output$dataframe_comparing_dataset_status <- renderText({ dataframe_comparing_dataset_status() })

        #

        # show the data information in a table
            selected_data_table_for_plot <- reactiveVal(NULL)
            output$dataframe_comparing_dataset <- renderDataTable({
                if(length(all_comapring_tables()) == 0 || length(all_comapring_tables()) == 0){
                    dataframe_comparing_dataset_status("No data to show. Please click the 'Start Analysis' button after setting the inputs and selecting the datasets for comparison.")
                    return(NULL)
                } else {
                    # if none of the gene is selected in the input gene list
                    if(length(input$Gene_comparing_gene_list_table_rows_selected) == 0){
                        dataframe_comparing_dataset_status("No gene selected. Please select a gene from the input gene list.")
                        return(NULL)
                    } else {
                        gene_selected <- used_genes()[input$Gene_comparing_gene_list_table_rows_selected]
                        comparing_tables_list <- all_comapring_tables()
                        comparing_tables_list_sub <- lapply(comparing_tables_list, function(x) x[x$id == gene_selected, ])
                        comparing_tables_list_sub_df <- do.call(rbind, comparing_tables_list_sub)
                        comparing_tables_list_sub_df$Dataset <- rep(names(comparing_tables_list), sapply(comparing_tables_list_sub, nrow))
                        dataframe_comparing_dataset_status(paste0("Showing the data for gene: ", gene_selected, "."))
                        selected_data_table_for_plot(comparing_tables_list_sub_df[, c('Dataset', 'Y_axis', 'Colour')])
                        datatable(selected_data_table_for_plot(), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)
                    }
                }
            })

        #

        # download the table
            output$comparing_dataset_download <- downloadHandler(
            filename = function(){"comparing_score_across_dataset.tsv"},
            content = function(fname){ write.table(dataframe_comparing_dataset_display_table(), fname, sep='\t', quote=F) }
            )
        #

    ##


    ## plot
        # status
            Gene_comparing_plot_status <- reactiveVal(NULL)
            output$Gene_comparing_plot_status <- renderText({ Gene_comparing_plot_status() })
        #

        # plot
            output$Gene_comparing_plot <- renderPlot({
                # analysis is not yet
                if(length(all_comapring_tables()) == 0 || length(all_comapring_tables()) == 0){
                    Gene_comparing_plot_status("No data to plot. Please click the 'Start Analysis' first.")
                    return(ggplot())
                }

                # if none of the gene is selected in the input gene list
                if(length(input$Gene_comparing_gene_list_table_rows_selected) == 0){
                    Gene_comparing_plot_status("No gene selected. Please select a gene from the input gene list to plot.")
                    return(ggplot())
                }

                # load the table for plotting
                gene_selected <- used_genes()[input$Gene_comparing_gene_list_table_rows_selected]
                selected_data_table_for_plot <- selected_data_table_for_plot()

                # sort the dataset by the Y axis value for better visualisation
                selected_data_table_for_plot <- selected_data_table_for_plot[order(selected_data_table_for_plot$Y_axis, decreasing = TRUE, na.last = TRUE), ]
                selected_data_table_for_plot$Dataset <- factor(selected_data_table_for_plot$Dataset, levels = unique(selected_data_table_for_plot$Dataset))

                # if the selected gene has no data in all the datasets, show message
                # check the Y_axis is all NA
                if(all(is.na(selected_data_table_for_plot$Y_axis))){
                    Gene_comparing_plot_status(paste0("The selected gene: ", gene_selected, " has no data in the selected datasets."))
                    return(ggplot())
                }

                # if the Y-axis value is NA, remove the dataset for plotting and later show a message about which datasets do not have the selected gene
                if(any(is.na(selected_data_table_for_plot$Y_axis))){
                    datasets_with_na <- selected_data_table_for_plot$Dataset[is.na(selected_data_table_for_plot$Y_axis)]
                    Gene_comparing_plot_status(paste0("The selected gene: ", gene_selected, " has no data in the following datasets: \n", paste(datasets_with_na, collapse = ', '), ". \n\nThese datasets will be removed from the plot."))
                    selected_data_table_for_plot <- selected_data_table_for_plot[!is.na(selected_data_table_for_plot$Y_axis), ]
                } else {
                    Gene_comparing_plot_status(NULL)
                }

                # Make a ggplot. colour_name is not set, do not set anything for the fill and color
                if(length(colour_name()) == 0 || is.null(colour_name())){
                    p <- ggplot(selected_data_table_for_plot, aes(x = Dataset, y = Y_axis))
                } else {
                    p <- ggplot(selected_data_table_for_plot, aes(x = Dataset, y = Y_axis, fill=Colour, color=Colour))
                }

                # either a scatter plot or a bar plot
                if(input$bar_or_scatter == "Scatter plot"){
                    p <- p + geom_point(size = input$Compare_pt.size)
                }else if (input$bar_or_scatter == "Bar plot") {
                    p <- p + geom_bar(stat = "identity")
                }

                # change the color scale ( only when colour option is selected )
                if(length(colour_name()) > 0 && !is.null(colour_name())){
                    values_for_colours <- selected_data_table_for_plot$Colour[!is.na(selected_data_table_for_plot$Colour)]
                    if( min(values_for_colours)<0 ){
                        if( max(values_for_colours)>=0 ){
                            if(input$Compare_manual_colour_range == FALSE){
                            tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                            p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=colour_name())
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=colour_name())
                            }else{
                            max_col <- input$Compare_manual_colour_range_high
                            min_col <- input$Compare_manual_colour_range_low
                            p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(min_col, 0, max_col)) , limits = c(min_col, max_col), name=colour_name(), oob = scales::squish)
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(min_col, 0, max_col)) , limits = c(min_col, max_col), name=colour_name(), oob = scales::squish)
                            }
                            # tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                            # p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=colour_name())
                            # p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=colour_name())
                            p <- p + geom_hline(yintercept=0, linetype='dotted', linewidth=0.1)
                        }else{
                            if(input$Compare_manual_colour_range == FALSE){
                            p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(values_for_colours), 0))  , limits = c(c(min(selected_data_table_for_plot$Colour), 0)), name=colour_name())
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(values_for_colours), 0))  , limits = c(c(min(selected_data_table_for_plot$Colour), 0)) , name=colour_name())
                            }else{
                            max_col <- input$Compare_manual_colour_range_high
                            min_col <- input$Compare_manual_colour_range_low
                            p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min_col, max_col))  , limits = c(c(min_col, max_col)), name=colour_name(), oob = scales::squish)
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min_col, max_col))  , limits = c(c(min_col, max_col)) , name=colour_name(), oob = scales::squish)
                            }
                        }
                    }else{
                        if(input$Compare_manual_colour_range == FALSE){
                            p <- p + scale_color_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(selected_data_table_for_plot$Colour)))  , limits = c(0,max(selected_data_table_for_plot$Colour)) , name=colour_name())
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(selected_data_table_for_plot$Colour)))  , limits = c(0,max(selected_data_table_for_plot$Colour)) , name=colour_name())
                        }else{
                            max_col <- input$Compare_manual_colour_range_high
                            min_col <- input$Compare_manual_colour_range_low
                            p <- p + scale_color_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(min_col, max_col))  , limits = c(c(min_col, max_col)) , name=colour_name(), oob = scales::squish)
                            p <- p + scale_fill_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(min_col, max_col))  , limits = c(c(min_col, max_col)) , name=colour_name(), oob = scales::squish)
                        }
                    }
                }

                # horizontal line at y=0
                p <- p + geom_hline(yintercept=0, linetype='dotted', linewidth=0.1)

                # other settings
                p <- p + ggtitle(gene_selected)
                p <- p + labs(x= 'Datasets',  y = Y_axis_name())
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_graph.title.font.size))
                p <- p + theme(axis.text.y = element_text(size = input$Compare_label.font.size), axis.text.x = element_text(size = input$Compare_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_title.font.size), axis.title.x = element_text(size = input$Compare_title.font.size))
                p <- p + theme(legend.text = element_text(size=input$Compare_label_legend_size), legend.title= element_text(size=input$Compare_label_legend_size))
                p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                if(input$Compare_white_background){
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                }
                p <- p + theme(legend.key.size = unit(1, "mm"))
                if(input$bar_or_scatter == "Scatter plot"){
                    if(min(selected_data_table_for_plot[,'Y_axis']) > 0){
                        p <- p + ylim(c(0, max(selected_data_table_for_plot[,'Y_axis'])))
                    }else if(max(selected_data_table_for_plot[,'Y_axis']) < 0){
                        p <- p + ylim(c(min(selected_data_table_for_plot[,'Y_axis']), 0))
                    }else{
                        p <- p + ylim(c(min(selected_data_table_for_plot[,'Y_axis']), max(selected_data_table_for_plot[,'Y_axis'])))
                    }

                }
                if(input$Compare_manual_y_axis_range){
                    p <- p + coord_cartesian(ylim = c(input$Compare_manual_y_axis_range_low, input$Compare_manual_y_axis_range_high))
                }
                p

            }, width=reactive(input$Compare_fig.width), height=reactive(input$Compare_fig.height), res=300)

}
