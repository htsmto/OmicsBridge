# =============================================================================
# Epigenome - Motif Scan: Plot
# File: modules/Epigenome/05_Epigenome_motifScan_plot.R
# Purpose: Result table rendering, motif logo plot, significant motif list,
#          and download handler. Consumes reactive values from the scan
#          sub-module.
# Edit this file when: changing the result visualisation (logo plot, table),
#                       or the significant motif list threshold display.
# =============================================================================

motif_scan_plot_server <- function(input, output, session, Motif_scan_result, isCalculating_Motif_analysis, Motif_analysis_plot_status) {

        # Show the table
            output$Motif_analysis_table <- renderDataTable({
                if(isCalculating_Motif_analysis()) {
                    tmp <- data.frame(list('rank'=character(0), 'target'=character(0), 'id'=character(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
                    return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
                }else if(length(Motif_scan_result()) == 0 || is.null(Motif_scan_result())){
                    tmp <- data.frame(list('rank'=character(0), 'target'=character(0), 'id'=character(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
                    return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
                }else{
                    return(datatable(Motif_scan_result(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE), rownames=FALSE))
                }
            })
        #
        # download table
            output$Motif_analysis_table_download <- downloadHandler(
                filename = function() {
                    "Motif_analysis_table.tsv"
                },
                content = function(fname) {
                    # Guard clause inside content function
                    if (!isTriggered_Motif_analysis() || isCalculating_Motif_analysis() || is.null(Motif_scan_result())) {
                    return(NULL)
                    }
                    write.table(Motif_scan_result(), fname, sep = '\t', row.names = FALSE, quote = FALSE)
                }
            )
        #

        # show a logo
            output$Motif_analysis_plot <- renderPlot({
                if(isCalculating_Motif_analysis() || is.null(Motif_scan_result())){
                    return(ggplot())
                }
                selected_row <- input$Motif_analysis_table_rows_selected
                if(length(selected_row) == 0){
                    output$Motif_analysis_plot_status <- renderText({'Please select a row in the motif scan table.'})
                    return(ggplot())
                }
                select_id <- Motif_scan_result()[selected_row, 'id']
                pfm <- PWMLogn.hg19.MotifDb.Hsap@pwms[[select_id]]$pfm
                pfm_norm <- apply(pfm, 2, function(col) col / sum(col))
                output$Motif_analysis_plot_status <- renderText({NULL})
                p <- ggseqlogo::ggseqlogo(pfm_norm, method=input$Motif_analysis_plot_Y_axis)
                p <- p + theme(axis.title = element_text(size = input$Motif_analysis_plot_XY_title_size), axis.text = element_text(size = input$Motif_analysis_plot_XY_label_size))
                p

            }, width = reactive(input$Motif_analysis_fig.width), height = reactive(input$Motif_analysis_fig.height), res=300)
        #

        # show the significant motif list
            output$Motif_analysis_significant_motif_list <- renderText({
                if(is.null(Motif_scan_result()) || isCalculating_Motif_analysis()){
                    return(NULL)
                }else{
                    p_thr <- input$Motif_analysis_significant_threshold
                    tmp <- Motif_scan_result()[Motif_scan_result()$p.value < p_thr, ]
                    if(dim(tmp)[1] == 0){
                        return("No significant motifs found with the selected threshold.")
                    }
                    tmp <- tmp[order(tmp$p.value), ]
                    return(paste(tmp$id, collapse = "\n"))
                }
            })
        #
}
