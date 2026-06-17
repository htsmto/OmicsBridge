# =============================================================================
# Tools - Chromosomal Locus Finder: Orchestrator
# File: modules/Tools/03_Tools_FindLoci_server.R
# Purpose: Wires together the search and plot sub-modules for the Find Loci
#          tool. Source the sub-files and call the sub-module functions here.
# Edit this file when: adding new sub-modules, changing how reactive values
#                       are passed between search and plot, or restructuring
#                       the overall module layout.
# =============================================================================

# Sub-module sources
source('modules/Tools/03_Tools_FindLoci_search.R', local = TRUE)
source('modules/Tools/03_Tools_FindLoci_plot.R',   local = TRUE)


tools_findloci_Server_func1 <- function(input, output, session) {
    # Search sub-module: handles input, gene lookup, status messages
    search_vals <- findloci_search_server(input, output, session)

    # Plot sub-module: renders result table and download handler
    findloci_plot_server(input, output, session,
        convert_table             = search_vals$convert_table,
        final_converted_gene_list = search_vals$final_converted_gene_list
    )
}

tools_findloci_Server_func2 <- function(input, output, session) {
    ## Initial settings
        # load a database
            Peak_annotation_txdb <- reactiveVal(NULL)
            annodb <- reactiveVal(NULL)
            observe({
                if(input$Peak_annotation_genome == 'hg38'){
                  Peak_annotation_txdb(loadDb("data/gencode.v41.primary_assembly.annotation.sqlite"))
                  annodb("org.Hs.eg.db")
                }
            })

        # Inputs and Settings
            Peak_annotation_status_input <- reactiveVal("Please enter peaks in the input box and click the 'Annotate the genomic locations' button.")
            input_coordinate_list <- reactiveVal(NULL)

        # annotation results
            Peak_annotation_status_results <- reactiveVal("The annotation results will be displayed here.")
            Peak_annotation_table_status <- reactiveVal("The annotation result table will be displayed here.")
            Peak_annotation_plot_status <- reactiveVal("The annotation distribution plot will be displayed here.")
            Peak_annotation_genes_list_status <- reactiveVal("The list of the genes closest to the input peaks will be displayed here.")

            # objects for results
            Peak_annotation <- reactiveVal(NULL) # the result of annotatePeak function
            Annotation_table <- reactiveVal(NULL) # the annotation result table extracted from the result of annotatePeak function
            Annotation_plot <- reactiveVal(NULL) # a ggplot object created from the result of annotatePeak
            Annotation_genes_list <- reactiveVal(NULL)

            # flags
            isTriggered_Peak_annotation <- reactiveVal(FALSE) # whether the annotation button is clicked
            isCalculating_Peak_annotation <- reactiveVal(FALSE) # whether the annotation is being calculated (between clicking the button and getting the results)


        # Status
            output$Peak_annotation_status_input <- renderText({ Peak_annotation_status_input() })
            output$Peak_annotation_status_results <- renderText({ Peak_annotation_status_results() })
            output$Peak_annotation_table_status <- renderText({ Peak_annotation_table_status() })
            output$Peak_annotation_plot_status <- renderText({ Peak_annotation_plot_status() })
            output$Peak_annotation_genes_list_status <- renderText({ Peak_annotation_genes_list_status() })

    ##

    ## Do peak annotation
        # Input peaks
            observe({
                if(length(input$Peak_annotation_input) > 0){
                    # when there are nothing in the text box
                    if(nchar(input$Peak_annotation_input) == 0){
                        Peak_annotation_status_input('Please enter peaks in the input box and click the "Annotate the genomic locations" button.')
                        input_coordinate_list(NULL)
                        return()
                    }

                    # Get the list of input peaks line by line, and remove empty lines
                    coordinate_list <- unique(unlist(strsplit(input$Peak_annotation_input, split='\n')))
                    coordinate_list <- coordinate_list[coordinate_list != ''] # remove empty elements

                    # if every element in the list is '', then set input_coordinate_list to NULL
                    if(length(coordinate_list) == 0){
                        Peak_annotation_status_input('Please enter peaks in the input box and click the "Annotate the genomic locations" button.')
                        input_coordinate_list(NULL)
                        return()
                    }

                    # update the input_coordinate_list
                    Peak_annotation_status_input(NULL)
                    input_coordinate_list(coordinate_list)
                } else {
                    Peak_annotation_status_input('Please enter peaks in the input box and click the "Annotate the genomic locations" button.')
                    input_coordinate_list(NULL)
                }
            })

        # Start annotation
            observeEvent(input$Peak_annotation_start, {
                # flgas
                isTriggered_Peak_annotation(TRUE)
                isCalculating_Peak_annotation(TRUE)

                # rename the objects
                coordinate_list <- input_coordinate_list()
                Peak_annotation_txdb <- Peak_annotation_txdb()
                annodb <- annodb()

                # when there is no coordinate in the input, show error message
                if(length(input_coordinate_list()) == 0 || is.null(input_coordinate_list())){
                    Peak_annotation_status_input('Please enter peaks in the input box first.')
                    show_alert(title = "Error", text = 'Please enter peaks in the input box first.', type = "error")
                    isCalculating_Peak_annotation(FALSE)
                    return()
                }

                # check if the input coordinates are in the correct format (chr:start-end)
                pattern_ok_peak <- coordinate_list[grepl("^[^\\s:]+:[0-9]+-[0-9]+$", coordinate_list)]

                # If all the input coordinates are not in the correct format, show error message
                if(length(pattern_ok_peak) == 0){
                    Peak_annotation_status_input('All the input peaks are not in the correct format ("chr:start-end"). Please enter peaks using the required format.')
                    Peak_annotation_status_results('All the input peaks are not in the correct format ("chr:start-end"). Please enter peaks using the required format.')
                    show_alert(title = "Error", text = 'All the input peaks are not in the correct format ("chr:start-end"). Please enter peaks using the required format.', type = "error")
                    isCalculating_Peak_annotation(FALSE)
                    return()
                }

                # Convert peaks to GRanges object
                chromosome <- sapply(strsplit(pattern_ok_peak, ":"), function(x) x[1])
                start <- as.numeric(sapply(strsplit(pattern_ok_peak, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][1])))
                end <- as.numeric(sapply(strsplit(pattern_ok_peak, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][2])))

                peaks_gr <- GRanges(seqnames = chromosome, ranges = IRanges(start = start, end = end))

                # check if the chromosomes in the input peaks are in the txdb
                available_chr <- Peak_annotation_txdb$user_seqlevels
                peaks_gr_filtered <- peaks_gr[seqnames(peaks_gr) %in% available_chr]

                # extract the valic peaks:
                valid <- start(peaks_gr_filtered) >= 1 & end(peaks_gr_filtered) >= start(peaks_gr_filtered) & end(peaks_gr_filtered) < 2^31-1 & width(peaks_gr_filtered) <= 1000000
                peaks_gr_filtered <- peaks_gr_filtered[valid]

                # when the Grange object after filtering is empty, show error message
                if(length(peaks_gr_filtered) == 0){
                    Peak_annotation_status_input('None of the input genomic locations can be found in the genome. Please check your input coordinates and try again.')
                    Peak_annotation_status_results('None of the input genomic locations can be found in the genome. Please check your input coordinates and try again.')
                    show_alert(title = "Error", text = 'None of the input genomic locations can be found in the genome. Please check your input coordinates and try again.', type = "error")
                    isCalculating_Peak_annotation(FALSE)
                    return()
                }

                # Do annotation
                peakAnno <- annotatePeak(peaks_gr_filtered,  TxDb = Peak_annotation_txdb, annoDb = annodb)

                # Result table. Add peakID (chr:start-end)
                res <- as.data.frame(peakAnno) # head(res)
                res$PeakID <- paste0(res$seqnames, ":", res$start, "-", res$end)
                res <- res[,c('PeakID', colnames(res)[1:length(colnames(res))-1])]

                # peaks that are correctly annotated and peaks that are not correctly annotated
                final_peaks <- res$PeakID
                not_annotated_peaks <- coordinate_list[!coordinate_list %in% final_peaks]

                # show status. show the list of peaks that were not annotated.
                if(length(not_annotated_peaks) > 0){
                    Peak_annotation_status_results(paste0("The following peaks were not annotated: \n", paste(not_annotated_peaks, collapse = ", "), "\nPossible reasons: 1. The input coordinate is not in the correct format (chr:start-end). 2. The input chromosome name is not in the genome. 3. The input coordinate is too large or too small, or the width of the input coordinate is larger than 100000.") )
                }else{
                    Peak_annotation_status_results("The annotation is completed. All the input peaks were annotated successfully.")
                }

                # update the objects for results
                Peak_annotation(peakAnno)
                Annotation_table(res)
                isCalculating_Peak_annotation(FALSE)
            })

    ##

    ## Results
        # Result1: annotation table
            # table output
            output$Peak_annotation_table <- renderDataTable({
                if(!isTriggered_Peak_annotation() || isCalculating_Peak_annotation() || length(Annotation_table()) == 0 || is.null(Annotation_table())){
                    tmp <- data.frame(list('PeakID'=character(0), 'Annotation'=character(0)), stringsAsFactors = FALSE )
                    datatable( tmp, options = list(scrollX = TRUE, pageLength = 10 ))
                }else{
                    Peak_annotation_table_status(NULL)
                    datatable(Annotation_table(), options = list(scrollX = TRUE, pageLength = 10 ))
                }
            })

            # download botton
            output$Peak_annotation_table_download <- downloadHandler(
              filename = function(){paste0("Peak_Annotation_Result_", Sys.Date(), ".tsv")},
              content = function(fname){ write.table(Annotation_table(), fname, sep='\t',  quote=FALSE, row.names = FALSE) }
            )

        # Result2: Plot
            # ggplot pbject
            # Note: I originally planned to create the plot from the default function in the ChIPseeker package, but they directly draw the figures without returning a ggplot object.
            #      So I decided to write my own code for creating a piechart and barplot.
            observe({
                if(!isTriggered_Peak_annotation() || isCalculating_Peak_annotation() || length(Annotation_table()) == 0 || is.null(Annotation_table())){
                    Annotation_plot(NULL)
                }else{
                    Peak_annotation_plot_status(NULL)
                    Annot_summary <- Peak_annotation()@annoStat # This returns "Feature" and "Frequency"

                    # ggplot object
                    if(input$Peak_annotation_plot_type == 'A'){
                        # piechart
                        p <- ggplot(Annot_summary, aes(x="", y=Frequency, fill=Feature)) +
                                geom_bar(stat="identity", width=1, color="white", linewidth=0.1) +
                                coord_polar("y", start=0)
                    }else { # barplot
                        # horizontal stacked barplot
                        Annot_summary <- Annot_summary %>% mutate(prop = Frequency / sum(Frequency))
                        p <- ggplot(Annot_summary, aes(x = "", y = prop, fill = Feature)) +
                            geom_bar(stat = "identity", width = 0.5, color = "white", linewidth = 0.1) +
                            coord_flip() +
                            scale_y_continuous(labels = scales::percent)
                    }
                    Annotation_plot(p)
                }
            })

            # plot output
            output$Peak_annotation_plot <- renderPlot({
                if(!isTriggered_Peak_annotation() || isCalculating_Peak_annotation() || length(Annotation_plot()) == 0 || is.null(Annotation_plot())){
                    ggplot()
                }else{
                    p <- Annotation_plot()
                    Annot_res <- Peak_annotation()

                    # Apply themes
                    # remove Y axis labels and ticks
                    p <- p + theme(axis.title.y = element_blank(),axis.text.y = element_blank(), axis.ticks.y = element_blank())
                    # piechart does not need X axis
                    if(input$Peak_annotation_plot_type == 'A'){
                        p <- p + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank())
                    }
                    # barplot need X axis
                    if(input$Peak_annotation_plot_type == 'B'){
                        p <- p + theme(axis.line.x=element_line(linewidth=0.1), axis.title.x = element_text(size = input$Peak_annotation_plot.X.size), axis.text.x = element_text(size = input$Peak_annotation_plot.X.size), axis.ticks.x = element_line(linewidth=0.05))
                        p <- p + xlab("Percentage")
                    }
                    # remove panel background and grid,
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    # change the legend text size, legend title size and legend key size
                    p <- p + theme(legend.text = element_text(size = input$Peak_annotation_legend.text.size))
                    p <- p + theme(legend.title = element_text(size = input$Peak_annotation_legend.title.size))
                    p <- p + theme(legend.key.size = unit(0.4, "cm"), legend.key.height = unit(0.3, "cm"), legend.key.width  = unit(0.3, "cm"))

                    return(p)

                }

            }, width=reactive(input$Peak_annotation_plot.width), height=reactive(input$Peak_annotation_plot.height), res=300)

        # Result3: list of nearest genes
            output$Peak_annotation_genes_list <- renderText({
                if(length(Annotation_table()) == 0 || is.null(Annotation_table())){
                    return("The list of the genes closest to the input peaks will be shown here.")
                }else{
                    Peak_annotation_genes_list_status(NULL)

                    # show the list of genes closest to the input peaks
                    if(input$Peak_annotation_genes_list_type == 'A'){
                        paste(unique(Annotation_table()$geneId[!is.na(Annotation_table()$geneId)]), collapse='\n')
                    }else{
                        paste(unique(Annotation_table()$SYMBOL[!is.na(Annotation_table()$SYMBOL)]), collapse='\n')
                    }
                }
            })

}
