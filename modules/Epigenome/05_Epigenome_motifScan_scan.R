# =============================================================================
# Epigenome - Motif Scan: Scan
# File: modules/Epigenome/05_Epigenome_motifScan_scan.R
# Purpose: PWMEnrich motif scanning calculation. Handles input UI rendering,
#          peak/sequence validation, and motifEnrichment execution. Returns
#          reactive values consumed by the plot sub-module.
# Edit this file when: changing the motif database, p-value cutoff logic,
#                       or the input validation for peaks/sequences.
# =============================================================================

motif_scan_server <- function(input, output, session) {
    ## Inputs and Settings
        # UI
            output$Motif_analysis_input_type_peaks <- renderUI({
                if(length(input$Motif_analysis_input_type) == 0 || input$Motif_analysis_input_type == 'B'){
                    return(NULL)
                } else {
                    return(
                        tagList(
                            textAreaInput(session$ns("Motif_analysis_input_peaks"), "Enter peaks (line by line)", placeholder='chr1:1000000-2000000\nchr1:2000000-3000000'),
                            radioButtons(session$ns("Motif_analysis_input_genome_type"), "Genome type", choices = c('hg38', 'hg19'), selected='hg38', inline=TRUE),
                            verbatimTextOutput(session$ns('Motif_analysis_input_status'))
                        )
                    )
                }
            })

            output$Motif_analysis_input_type_gene <- renderUI({
                if(length(input$Motif_analysis_input_type) == 0 || input$Motif_analysis_input_type == 'A'){
                    return(NULL)
                } else {
                    return(
                        tagList(
                            textAreaInput(session$ns("Motif_analysis_input_sequences"), "Enter sequences (line by line)", placeholder='ATCGATCGATCG\nGCTAGCTAGCTA')
                        )
                    )
                }
            })
        #
    ##

    ## motif scan
        # status
            Motif_analysis_input_status <- reactiveVal(NULL)
            Motif_analysis_status <- reactiveVal(NULL)
            Motif_analysis_plot_status <- reactiveVal(NULL)
            output$Motif_analysis_input_status <- renderText({ Motif_analysis_input_status() })
            output$Motif_analysis_status <- renderText({ Motif_analysis_status() })
            output$Motif_analysis_plot_status <- renderText({ Motif_analysis_plot_status() })
        #

        # genome selection -> genome(), either hg38 or hg19
            genome <- reactiveVal(NULL)
            observe({
                if(length(input$Motif_analysis_input_genome_type) == 0){
                    return(NULL)
                }else if(input$Motif_analysis_input_genome_type == 'hg38'){
                    genome(BSgenome.Hsapiens.UCSC.hg38)
                }else if(input$Motif_analysis_input_genome_type == 'hg19'){
                    genome(BSgenome.Hsapiens.UCSC.hg19)
                }
            })
        #

        # peak input -> seq_region_tmp_dataframe
            seq_region_tmp_dataframe <- reactiveVal(NULL)
            observe({
                if(length(input$Motif_analysis_input_type) == 0 || input$Motif_analysis_input_type == 'B'){
                    seq_region_tmp_dataframe(NULL)
                    return(NULL)
                }

                # no nothing is inputted or If all the input peaks are only spaces
                    if(length(input$Motif_analysis_input_peaks) == 0 || nchar(input$Motif_analysis_input_peaks) == 0){
                        Motif_analysis_input_status('Please input the peaks in the format of chr:start-end.')
                        seq_region_tmp_dataframe(NULL)
                        return(NULL)
                    }
                    if(all(grepl("^\\s*$", input$Motif_analysis_input_peaks))){
                        Motif_analysis_input_status('Please input the peaks in the format of chr:start-end.')
                        seq_region_tmp_dataframe(NULL)
                        return(NULL)
                    }
                #

                # process the input peaks. Remove the element that is only spaces or duplicated
                    peaks <- unlist(strsplit(input$Motif_analysis_input_peaks, split = "\n"))
                    peaks <- peaks[!peaks=='']
                    peaks <- unique(peaks)
                #

                # check the format of the input peaks
                    if(!all(grepl("^[^\\s:]+:[0-9]+-[0-9]+$", peaks))){
                        Motif_analysis_input_status("Some input peaks are not in the correct format ('chr:start-end'). Please enter peaks using the required format.")
                        seq_region_tmp_dataframe(NULL)
                        return(NULL)
                    }
                #

                # make a table for the input peaks
                    chromosome <- sapply(strsplit(peaks, ":"), function(x) x[1])
                    start <- as.numeric(sapply(strsplit(peaks, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][1])))
                    end <- as.numeric(sapply(strsplit(peaks, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][2])))
                    df_tmp <- data.frame(peaks=peaks, chr=chromosome, start=start, end=end)
                #

                # check if the chromosome exists in the genome
                    available_chr <- unique(genome()@seqinfo@seqnames)
                    df_tmp_in <- df_tmp[df_tmp$chr %in% available_chr, ] # the peaks with chromosome existing in the genome
                    df_tmp_out <- df_tmp[!df_tmp$chr %in% available_chr, ] # the peaks with chromosome not existing in the genome
                #

                # if no peaks with chromosome existing in the genome
                    if(dim(df_tmp_in)[1] == 0){
                        Motif_analysis_input_status("The selected locations do not exist in the genome.")
                        seq_region_tmp_dataframe(NULL)
                        return(NULL)
                    }
                #

                # if there are peaks with chromosome not existing in the genome
                    if(dim(df_tmp_out)[1] > 0){
                        error_msg_out <- paste("\nThe following peaks do not exist in the genome and will be ignored:\n", paste(df_tmp_out$peaks, collapse = "\n"))
                    }else{
                        error_msg_out <- NULL
                    }
                #

                # show how many peaks will be used for the motif scan
                    message <- paste0("You have inputted ", dim(df_tmp_in)[1], " peaks.")
                    if(!is.null(error_msg_out)){
                        message <- paste(c(message, error_msg_out), collapse = "\n")
                    }
                # return the datarame
                    Motif_analysis_input_status(message)
                    seq_region_tmp_dataframe(df_tmp_in)
            })
        #


        # Motif scan
            Motif_scan_result <- reactiveVal(NULL)
            isCalculating_Motif_analysis <- reactiveVal(FALSE)

            observeEvent(input$Motif_analysis_start,{
                isCalculating_Motif_analysis(TRUE)

                # database
                    genome <- genome()
                #

                # create the input
                if(input$Motif_analysis_input_type == 'A'){

                    # No input
                        if(length(seq_region_tmp_dataframe()) == 0 || is.null(seq_region_tmp_dataframe())){
                            show_alert(title='Error.',text='Please input the peaks in the format of chr:start-end.', type='error')
                            Motif_analysis_status('Please input the peaks in the format of chr:start-end.')
                            Motif_analysis_plot_status('Please do the motif scan first.')
                            Motif_scan_result(NULL)
                            isCalculating_Motif_analysis(FALSE)
                            return(NULL)
                        }
                    #

                    # input is fine.
                    seq_region <- getSeq(genome, names=seq_region_tmp_dataframe()$chr, start=seq_region_tmp_dataframe()$start, end=seq_region_tmp_dataframe()$end)

                    # check if the input sequences contain characters other than A, T, G, and C
                    seq_region_clean <- seq_region[grepl("^[ACGT]+$", as.character(seq_region))]
                    seq_region_with_non_acgt <- seq_region[!grepl("^[ACGT]+$", as.character(seq_region))] # the selected region dose not contain A,T,G,C (or not defined)
                    error_msg_atcg <- NULL
                    error_msg_out <- NULL
                    if(length(seq_region_with_non_acgt) > 0 ){
                        if(length(seq_region_clean) == 0){
                            show_alert(title='Error.',text='The selected region does not contain A,T,G,C. Please select another region.', type='error')
                            Motif_analysis_status("The selected region does not contain A,T,G,C. Please select another region.")
                            Motif_analysis_plot_status('Please do the motif scan first.')
                            Motif_scan_result(NULL)
                            isCalculating_Motif_analysis(FALSE)
                            return(NULL)
                        }else{
                            error_peak <- seq_region_tmp_dataframe()$peaks[!grepl("^[ACGT]+$", as.character(seq_region))]
                            error_msg_atcg <- paste("The following peaks do not contain A,T,G,C and will be ignored:\n", paste(error_peak, collapse = "\n"))
                        }
                    }else{
                        Motif_analysis_status(NULL)
                    }

                    if(!is.null(error_msg_atcg)){
                        if(!is.null(error_msg_out)){
                            Motif_analysis_status(paste(c(error_msg_out, error_msg_atcg), collapse = "\n"))
                        }else{
                            Motif_analysis_status(error_msg_atcg)
                        }
                    }else if(!is.null(error_msg_out)){
                        Motif_analysis_status(error_msg_out)
                    }else{
                        Motif_analysis_status(NULL)
                    }
                }


                else if(input$Motif_analysis_input_type == 'B'){
                    if(nchar(input$Motif_analysis_input_sequences) == 0){
                        show_alert(title='Error.',text='Please input the sequences in the format of ACGT.', type='error')
                        Motif_analysis_status('Please input the sequences in the format of ACGT.')
                        Motif_analysis_plot_status('Please do the motif scan first.')
                        isCalculating_Motif_analysis(FALSE)
                        return(NULL)
                    }
                    seq_region <- unlist(strsplit(input$Motif_analysis_input_sequences, split = "\n"))
                    seq_region <- unique(seq_region)
                    seq_region_clean <- seq_region[grepl("^[ACGT]+$", as.character(seq_region))]
                    seq_region_with_non_acgt <- seq_region[!grepl("^[ACGT]+$", as.character(seq_region))] # the selected region dose not contain A,T,G,C (or not defined)
                    if(length(seq_region_with_non_acgt) > 0 ){
                        if(length(seq_region_clean) == 0){
                        show_alert(title='Error.',text='The input sequences contain characters other than A, T, G, and C. Please enter the sequences again.', type='error')
                        Motif_analysis_status('The input sequences contain characters other than A, T, G, and C. Please enter the sequences again.')
                        Motif_analysis_plot_status('Please do the motif scan first.')
                        isCalculating_Motif_analysis(FALSE)
                        return(NULL)
                        }else{
                        Motif_analysis_status(paste("The following sequences contain characters other than A, T, G, and C, and will be ignored:\n", paste(seq_region_with_non_acgt, collapse = "\n")))
                        }
                    }else{
                        Motif_analysis_status(NULL)
                    }
                    seq_region_clean <- DNAStringSet(seq_region_clean) # convert to DNAStringSet
                }

                # scan
                max_length <- min(nchar(seq_region_clean))
                if(max_length < 6){
                    show_alert(title='Error.',text='The length of the sequences is too short. Please input sequences with a length of at least 6.', type='error')
                    Motif_analysis_status('The length of the sequences is too short. Please input sequences with a length of at least 6.')
                    Motif_analysis_plot_status('Please do the motif scan first.')
                    isCalculating_Motif_analysis(FALSE)
                    return(NULL)
                }else if(max_length < 23){
                    show_alert(title='Warning.',text='The length of the sequences is very short. Only the motifs longer than the input sequences are used.', type='warning')
                    seq_len_less_than_thr <- c()
                    pwms <- PWMLogn.hg19.MotifDb.Hsap$pwms
                    for (i in seq_along(pwms)){
                            seq_len_less_than_thr <- c(seq_len_less_than_thr, dim(pwms[[i]]$pwm)[2] <= max_length)
                    }
                    pwms_small <- pwms[seq_len_less_than_thr]
                    pwms_small_names <- names(pwms_small)
                    PWMLogn.hg19.MotifDb.Hsap_small <- PWMLogn.hg19.MotifDb.Hsap
                    PWMLogn.hg19.MotifDb.Hsap_small@pwms <- pwms_small
                    PWMLogn.hg19.MotifDb.Hsap_small@bg.source <- PWMLogn.hg19.MotifDb.Hsap@bg.source
                    PWMLogn.hg19.MotifDb.Hsap_small@bg.len <- PWMLogn.hg19.MotifDb.Hsap@bg.len[,pwms_small_names]
                    PWMLogn.hg19.MotifDb.Hsap_small@bg.mean <- PWMLogn.hg19.MotifDb.Hsap@bg.mean[,pwms_small_names]
                    PWMLogn.hg19.MotifDb.Hsap_small@bg.sd <- PWMLogn.hg19.MotifDb.Hsap@bg.sd[,pwms_small_names]
                    res = motifEnrichment(seq_region_clean, PWMLogn.hg19.MotifDb.Hsap_small)
                }else{
                    res = motifEnrichment(seq_region_clean, PWMLogn.hg19.MotifDb.Hsap)
                }
                report = groupReport(res)
                Motif_analysis_plot_status('Please select a row in the motif scan table.')
                Motif_scan_result(df_report <- as.data.frame(report))
                isCalculating_Motif_analysis(FALSE)
                return(NULL)
            })
        #

    ##

    return(list(
        Motif_scan_result = Motif_scan_result,
        isCalculating_Motif_analysis = isCalculating_Motif_analysis,
        Motif_analysis_plot_status = Motif_analysis_plot_status
    ))
}
