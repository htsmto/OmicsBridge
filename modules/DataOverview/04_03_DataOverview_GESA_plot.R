# =============================================================================
# DataOverview - GSEA: Plot & Result Table
# File: modules/DataOverview/04_03_DataOverview_GESA_plot.R
# Purpose: Renders the fgsea enrichment plot for the selected pathway, the
#          result table, and the download handler for the result table.
# Edit this file when: changing enrichment plot style, table columns,
#                       or the download file format.
# Libraries required: fgsea, ggplot2 (loaded via libraries_DataOverview.R)
# =============================================================================

gsea_plot_server <- function(input, output, session, df_ex, GSEA_results, GSEA_Gene_set_after_start, ranked_score, isCalculating) {
    ## Result table
        # status
            GSEA_goTable_status <- reactiveVal(NULL)
            output$GSEA_goTable_status <- renderText({ GSEA_goTable_status() })
        #

        # result table
            output$GSEA_goTable <- DT::renderDataTable({
                if(isCalculating()){
                    GSEA_goTable_status(NULL)
                    return(NULL)
                }

                else if(length(GSEA_results()) == 0 || is.null(GSEA_results())){
                    GSEA_goTable_status('The GSEA result will be shown here after the analysis is completed.')
                    tmp <- as.data.frame(list('pathway'=character(0), 'pval'=character(0), 'ES'=character(0), 'NES'=character(0), 'size'=character(0), 'log2err'=character(0), 'padj'=character(0)))
                    datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
                }else{
                    GSEA_goTable_status(NULL)
                    tmp <- as.data.frame(GSEA_results())
                    datatable(tmp[, c('pathway', 'pval', 'padj', 'log2err', 'ES', 'NES', 'size')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                }
            })
        #

        # download button
            output$GSEA_download <- downloadHandler(
                filename = function(){"GSEA_results.csv"},
                content = function(fname){ write.csv(as.data.frame(GSEA_results()), fname) }
            )
        #

    ##

    ## Plot
        # status
            GSEA_status <- reactiveVal(NULL)
            output$GSEA_status <- renderText({ GSEA_status() })
        #

        # GSEA plot
            output$GSEA_plot <- renderPlot({
                if(length(GSEA_results()) == 0 || is.null(GSEA_results())){
                    GSEA_status('The GSEA enrichment plot will be shown here after you select a pathway from the GSEA results table.')
                    return(ggplot())
                }

                # when no pathway is selected from the result table
                else if(length(input$GSEA_goTable_rows_selected) == 0){
                  GSEA_status('Please select the pathway (row) from the GSEA results table')
                  return(ggplot())
                }


                fgseaRes2 <- GSEA_results()

                GSEA_select_score <- ranked_score()
                ranked_genes <- df_ex()[,GSEA_select_score]
                names(ranked_genes) <- df_ex()$id
                selected_pathway <- fgseaRes2[input$GSEA_goTable_rows_selected,]$pathway
                p <- plotEnrichment(GSEA_Gene_set_after_start()[[selected_pathway]],ranked_genes) + labs(title=selected_pathway)
                p <- p + theme(axis.text=element_text(size=input$GSEA_lab.font.size), axis.title=element_text(size=input$GSEA_title.font.size))
                p <- p + theme(plot.title = element_text(size = input$GSEA_graph_title.font.size))

                # show the result
                message<-  paste0('P value: ', as.character(fgseaRes2[fgseaRes2$pathway==selected_pathway,]$pval), '\n',
                    'adjusted-P value: ', as.character(fgseaRes2[fgseaRes2$pathway==selected_pathway,]$padj), '\n',
                    'ES: ', as.character(fgseaRes2[fgseaRes2$pathway==selected_pathway,]$ES), '\n',
                    'NES: ', as.character(fgseaRes2[fgseaRes2$pathway==selected_pathway,]$NES), '\n',
                    'size: ', as.character(fgseaRes2[fgseaRes2$pathway==selected_pathway,]$size))
                GSEA_status(message)

                p$layers[[1]]$aes_params$colour <- input$GSEA_graph_line_colour
                p$layers[[3]]$aes_params$colour <- input$GSEA_graph_maxmin_line_colour
                p$layers[[4]]$aes_params$colour <- input$GSEA_graph_maxmin_line_colour
                p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p
            }, width=reactive(input$GSEA_fig.width), height=reactive(input$GSEA_fig.height),res=300)
        #

    ##
}
