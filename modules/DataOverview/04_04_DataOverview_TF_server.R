# =============================================================================
# DataOverview - Transcription Factor Inference Server
# File: modules/DataOverview/04_04_DataOverview_TF_server.R
# Purpose: Infers transcription factor activity from expression data using
#          DoRothEA / VIPER. Renders a TF activity bar plot and result table.
# Edit this file when: changing the TF regulon database, the activity
#                       scoring method, or result visualisation.
# Libraries required: viper, dorothea (loaded via libraries_DataOverview.R)
# =============================================================================

dataoverview_TF_Server <- function(input, output, session, df_ex) {
    ## Input and Start
    ##

    ## Start DecoupeR
        # status
            DecoupeR_plot_status <- reactiveVal("Set the parameters and click 'Start DecoupeR Analysis' to run the analysis.")
            output$DecoupeR_plot_status <- renderText({ DecoupeR_plot_status() })
        #

        # start
            DecoupeR_TF_table_all <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            observeEvent(input$DecoupeR_start, {
                isCalculating(TRUE)   
                df_LFC <- df_ex()
                rownames(df_LFC) <- df_LFC$id
                if(!'stat' %in% colnames(df_LFC)){
                    DecoupeR_plot_status('The input data is not the RANseq DEG data processed by DESeq2, and cannot applicable to this function.')
                    DecoupeR_TF_table_all(NULL)
                    isCalculating(FALSE)
                    return()
                }else{
                    DecoupeR_plot_status(NULL)
                    contrast_acts <- decoupleR::run_ulm(mat=df_LFC[, 'stat', drop=FALSE], net=net, .source='source', .target='target', .mor='mor', minsize = 5)
                    contrast_acts <- contrast_acts[order(contrast_acts$score, decreasing = TRUE), ]
                    DecoupeR_TF_table_all(contrast_acts)
                    isCalculating(FALSE)
                    return()
                }
            })
        #
    ##

    ## results
        ## table
            # status
                DecoupeR_Table_status <- reactiveVal("The results table will be displayed here after the analysis is completed.")
                output$DecoupeR_Table_status <- renderText({ DecoupeR_Table_status() })
            #

            # show a table
                output$DecoupeR_Table <- DT::renderDataTable({
                    if(isCalculating()) {
                        return(NULL)
                    }else if(length(DecoupeR_TF_table_all()) == 0 || is.null(DecoupeR_TF_table_all())){ 
                        DecoupeR_Table_status('The result of the DecoupleR analysis (the activity level of transcription factors) will be shown here.')
                        tmp <- as.data.frame(list('statistic'=character(0), 'source'=character(0), 'condition'=character(0), 'score'=character(0), 'p.value'=character(0)))
                        datatable(tmp,  options = list(scrollX = TRUE, pageLength = 10))
                    }else{ 
                        DecoupeR_Table_status(NULL)
                        datatable(DecoupeR_TF_table_all(), options = list(scrollX = TRUE)) 
                    }
                })
            #

            # download the table
                output$DecoupeR_Table_download <- downloadHandler(
                    filename = function(){"decoupleR.tsv"}, 
                    content = function(fname){ write.table(DecoupeR_TF_table_all(), fname, sep='\t', row.names=F, quote=F) }
                )
            #

        ##

        ## Plot
            # status
                DecoupeR_plot_status2 <- reactiveVal("The plot will be displayed here after the analysis is completed.")
                output$DecoupeR_plot_status2 <- renderText({ DecoupeR_plot_status2() })
            #

            # output table
                DecoupeR_TF_table <- reactiveVal(NULL)
                observe({
                    if(length(DecoupeR_TF_table_all()) == 0 || is.null(DecoupeR_TF_table_all())){
                        DecoupeR_TF_table(NULL)
                    }else{
                        f_contrast_acts <- DecoupeR_TF_table_all() %>% mutate(rnk = NA)
                        msk <- f_contrast_acts$score > 0
                        f_contrast_acts[msk, 'rnk'] <- rank(-f_contrast_acts[msk, 'score'])
                        f_contrast_acts[!msk, 'rnk'] <- rank(-abs(f_contrast_acts[!msk, 'score']))
                        tfs <- f_contrast_acts %>% arrange(rnk) %>% head(input$DecoupeR_TF_number) %>% pull(source)
                        f_contrast_acts <- f_contrast_acts %>% filter(source %in% tfs)
                        DecoupeR_TF_table(f_contrast_acts)
                    }
                })
            #

            # plot
                output$DecoupeR_plot <- renderPlot({
                    if(isCalculating()) {
                        return(ggplot())
                    }else if(is.null(DecoupeR_TF_table())){
                        DecoupeR_plot_status2('The plot of transcription factor activities will be shown here.')
                        return(ggplot())
                    }else{
                        # explain how many TFs are shown. Top X of activated and top Y deactivated TFs based on the score changes.
                        message <- paste0("Showing the top ", sum(DecoupeR_TF_table()$score > 0), " activated TFs and top ", sum(DecoupeR_TF_table()$score < 0), " deactivated TFs based on the score changes.")
                        DecoupeR_plot_status2(message)
                        p <- ggplot(DecoupeR_TF_table(), aes(x = reorder(source, score), y = score)) + geom_bar(aes(fill = score), stat = "identity")
                        p <- p + scale_fill_gradient2(low = input$DecoupeR_colour_low, high = input$DecoupeR_colour_high, mid = input$DecoupeR_colour_mid, midpoint = 0)
                        p <- p + theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust = 1)) + xlab("TFs")
                        p <- p + theme(axis.text=element_text(size=input$DecoupeR_lab.font.size), axis.title=element_text(size=input$DecoupeR_title.font.size))
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                        p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        p <- p + theme(legend.text = element_text(size = input$DecoupeR_legend.size), legend.title = element_text(size = input$DecoupeR_legend.size) )
                        p <- p + theme(legend.key.size = unit(1, "mm"))
                        p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                        if(input$DecoupeR_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", size=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p
                    }
                }, width=reactive(input$DecoupeR_fig.width), height=reactive(input$DecoupeR_fig.height),res=300)
            #
        ##
    ##

}