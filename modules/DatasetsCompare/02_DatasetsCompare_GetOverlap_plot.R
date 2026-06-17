# =============================================================================
# DatasetsCompare - Gene Overlap: Plot & Table
# File: modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_plot.R
# Purpose: Renders the overlap result table, gene list selector, bar plot for
#          a selected gene, and download handler.
# Edit this file when: changing the overlap visualisation (Venn -> UpSet),
#                       plot styling, or gene list output format.
# =============================================================================

get_overlap_plot_server <- function(input, output, session, overlapped_genes_table, isCalculating_ovelap_hit) {

    ## Display the overlapped genes in a table
        # status
            Compare_dataset_get_overview_table_status <- reactiveVal(NULL)
            output$Compare_dataset_get_overview_table_status <- renderText({ Compare_dataset_get_overview_table_status() })

        #

        # display the overlapped genes table
            output$Compare_dataset_get_overview_overlap <- renderDataTable({
                if(isCalculating_ovelap_hit()){
                    Compare_dataset_get_overview_table_status('Calculating the overlapped genes, please wait...')
                    return()
                }
                if(is.null(overlapped_genes_table())){
                    Compare_dataset_get_overview_table_status('No result to show yet. Please click "Investigate the overlap" to see the result.')
                    return()
                } else {
                    Compare_dataset_get_overview_table_status(paste0("There are ", nrow(overlapped_genes_table()), " genes in the result."))
                    datatable(overlapped_genes_table(), options = list(pageLength = 10, scrollX = TRUE), selection = list(mode='single'),)
                }
            })

        #

        # donwload the overlapped genes table
            output$Compare_dataset_get_overview_download <- downloadHandler(
            filename = function(){"Compare_datasets_Overlap_table.tsv"},
            content = function(fname){ write.table(overlapped_genes_table(), fname, sep='\t', quote=F, row.names=F) }
            )
        #

        # show the list of the genes in the selected Overlap_times
            output$Compare_dataset_get_overview_list_genes_select <- renderUI({
                if(length(overlapped_genes_table()) == 0 || is.null(overlapped_genes_table())){
                    selectInput(session$ns('Compare_dataset_get_overview_list_genes_select'), 'Select the Overlap_times to show the genes in the list', choices = c('None'='None', 'All'='All'), selected = 'None')
                }
                selectInput(session$ns('Compare_dataset_get_overview_list_genes_select'), 'Select the Overlap_times to show the genes in the list', choices = c('None'='None', 'All'='All', sort(unique(overlapped_genes_table()$Overlap_times))), selected = 'None')
            })

            output$Compare_dataset_get_overview_list_genes_select_status <- renderText({
                if(length(input$Compare_dataset_get_overview_list_genes_select) == 0 ){
                    return(NULL)
                }
                if(length(overlapped_genes_table()) == 0 || is.null(overlapped_genes_table())){
                    return('No result to show yet. Please click "Investigate the overlap"')
                }else if(input$Compare_dataset_get_overview_list_genes_select == 'None'){
                    return('Please select the Overlap_times to show the genes in the list.')
                } else if(input$Compare_dataset_get_overview_list_genes_select == 'All'){
                    return(paste(overlapped_genes_table()$id, collapse = '\n'))
                } else {
                    genes_to_show <- overlapped_genes_table()[overlapped_genes_table()$Overlap_times == as.numeric(input$Compare_dataset_get_overview_list_genes_select), 'id']
                    return(paste(genes_to_show, collapse = '\n'))
                }
            })

    ##

    ## Plot a bar plot
        # status
            Compare_dataset_get_overview_barplot_status <- reactiveVal(NULL)
            output$Compare_dataset_get_overview_barplot_status <- renderText({ Compare_dataset_get_overview_barplot_status() })
        #

        # plot
            output$Compare_dataset_get_overview_barplot <- renderPlot({
                if(!is.null(overlapped_genes_table())){
                    if(length(input$Compare_dataset_get_overview_overlap_rows_selected)>0){
                        Compare_dataset_get_overview_barplot_status(NULL)

                        # detect the data info
                        data_to_show <- overlapped_genes_table()[input$Compare_dataset_get_overview_overlap_rows_selected,]
                        gene <- data_to_show$id
                        df_plot <- na.omit(data.frame(t(data_to_show[,3:dim(data_to_show)[2]]))) # remove 'id' and 'Overlap_times' columns
                        colnames(df_plot) <- c('Score')
                        df_plot$sample <- rownames(df_plot)
                        df_plot <- df_plot[order(df_plot$Score, decreasing = T),]
                        df_plot$sample <- factor(df_plot$sample, levels=df_plot$sample)

                        # plot
                        p <- ggplot(df_plot, aes(x= .data[["sample"]], y=.data[["Score"]], fill=.data[["Score"]])) + geom_bar(stat='identity')
                        values_for_colours <- df_plot[,'Score']
                        # horizontal line. y=0
                        p <- p + geom_hline(yintercept = 0, color='black', linewidth=0.1)

                        lo  <- input$Compare_dataset_get_overview_lowest_colour
                        hi  <- input$Compare_dataset_get_overview_highest_colour
                        zer <- input$Compare_dataset_get_overview_zero_colour
                        score_name <- input$Compare_dataset_get_overview_select_score
                        use_manual_col <- isTRUE(input$Compare_dataset_get_overview_manual_colour_range)

                        if (use_manual_col) {
                            max_col <- input$Compare_dataset_get_overview_manual_colour_range_high
                            min_col <- input$Compare_dataset_get_overview_manual_colour_range_low
                            p <- p + scale_color_gradientn(colors=c(lo, zer, hi), values=scales::rescale(c(min_col, 0, max_col)), limits=c(min_col, max_col), name=score_name, oob=scales::squish)
                            p <- p + scale_fill_gradientn( colors=c(lo, zer, hi), values=scales::rescale(c(min_col, 0, max_col)), limits=c(min_col, max_col), name=score_name, oob=scales::squish)
                        } else if (min(values_for_colours) < 0) {
                            if (max(values_for_colours) >= 0) {
                                tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                                p <- p + scale_color_gradientn(colors=c(lo, zer, hi), values=scales::rescale(c(-tmp, 0, tmp)), limits=c(-tmp, tmp), name=score_name)
                                p <- p + scale_fill_gradientn( colors=c(lo, zer, hi), values=scales::rescale(c(-tmp, 0, tmp)), limits=c(-tmp, tmp), name=score_name)
                            } else {
                                p <- p + scale_color_gradientn(colors=c(lo, zer), values=scales::rescale(c(min(values_for_colours), 0)), limits=c(min(values_for_colours), 0), name=score_name)
                                p <- p + scale_fill_gradientn( colors=c(lo, zer), values=scales::rescale(c(min(values_for_colours), 0)), limits=c(min(values_for_colours), 0), name=score_name)
                            }
                        } else {
                            p <- p + scale_color_gradientn(colors=c(zer, hi), values=scales::rescale(c(0, max(values_for_colours))), limits=c(0, max(values_for_colours)), name=score_name)
                            p <- p + scale_fill_gradientn( colors=c(zer, hi), values=scales::rescale(c(0, max(values_for_colours))), limits=c(0, max(values_for_colours)), name=score_name)
                        }
                        if (isTRUE(input$Compare_dataset_get_overview_manual_y_axis_range)) {
                            p <- p + coord_cartesian(ylim = c(input$Compare_dataset_get_overview_manual_y_axis_range_low, input$Compare_dataset_get_overview_manual_y_axis_range_high))
                        }
                        p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_dataset_get_overview_graph.title.font.size))
                        p <- p + theme(axis.text.y = element_text(size = input$Compare_dataset_get_overview_label.font.size), axis.text.x = element_text(size = input$Compare_dataset_get_overview_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_dataset_get_overview_title.font.size), axis.title.x = element_text(size = input$Compare_dataset_get_overview_title.font.size))
                        p <- p + ggtitle(gene)
                        p <- p + theme(legend.text = element_text(size=input$Compare_dataset_get_overview_legend_size), legend.title= element_text(size=input$Compare_dataset_get_overview_legend_size))
                        p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                        p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        p <- p + theme(legend.key.size = unit(2, "mm"))
                        if(input$Compare_dataset_get_overview_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p
                    }else{ # The table is there but no row is selected
                        Compare_dataset_get_overview_barplot_status("Please select a row from the table")
                        return(ggplot())

                    }


                }else{ # the table does not exist yet. (not investigating the overlap yet)
                    Compare_dataset_get_overview_barplot_status("Please set the input and start analysis first.")
                    return(ggplot())

                }
            }, width=reactive(input$Compare_dataset_get_overview_fig.width), height=reactive(input$Compare_dataset_get_overview_fig.height), res=300)

}
