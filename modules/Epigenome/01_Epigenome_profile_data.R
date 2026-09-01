# =============================================================================
# Epigenome - Profile Plot: Data
# File: modules/Epigenome/01_Epigenome_profile_data.R
# Purpose: BigWig loading, sample import/removal, and genomic region
#          preparation (normalizeToMatrix). Returns reactive values consumed
#          by the plot sub-module.
# Edit this file when: changing the signal normalisation, region set parsing,
#                       or the sample import/removal logic.
# =============================================================================

epigenome_profile_data_server <- function(input, output, session, Dataset) {
    ## Input and Settings
        # Input samples
            # status
                Profile_Plot_sample_selection_status <- reactiveVal('Please select a dataset and click the "Import the selected sample".')
                output$Profile_Plot_sample_selection_status <- renderText({ Profile_Plot_sample_selection_status() })
            #

            # sample filtering
                output$Profile_Plot_sample_selection_Sequenced_by <- renderUI({
                    df_tmp <- Dataset()
                    df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
                    selectInput(session$ns('Profile_Plot_sample_selection_Sequenced_by'), 'Data from', c('None'='None', unique(df_tmp$Data.from)) )
                })

                output$Profile_Plot_sample_selection_Experiments <- renderUI({
                    df_tmp <- Dataset()
                    df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
                    if(length(input$Profile_Plot_sample_selection_Sequenced_by)>0){
                    if(input$Profile_Plot_sample_selection_Sequenced_by!='None'){
                        df_tmp <- df_tmp[df_tmp$Data.from == input$Profile_Plot_sample_selection_Sequenced_by,]
                    }
                    }
                    selectInput(session$ns('Profile_Plot_sample_selection_Experiments'), 'Experiment name', c('None'='None', unique(df_tmp$Experiment)) )
                })

            #

            # sample selection
                output$Profile_Plot_sample_selection <- renderUI({
                    df_tmp <- Dataset()
                    df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
                    if(length(input$Profile_Plot_sample_selection_Sequenced_by)>0){
                        if(input$Profile_Plot_sample_selection_Sequenced_by!='None'){
                            df_tmp <- df_tmp[df_tmp$Data.from == input$Profile_Plot_sample_selection_Sequenced_by,]
                        }
                    }
                    if(length(input$Profile_Plot_sample_selection_Experiments)>0){
                        if(input$Profile_Plot_sample_selection_Experiments!='None'){
                            df_tmp <- df_tmp[df_tmp$Experiment == input$Profile_Plot_sample_selection_Experiments,]
                        }
                    }
                    selectInput(session$ns('Profile_Plot_sample_selection'), 'Dataset select', c('None'='None', unique(df_tmp$Dataset)) )
                })
            #

            # Import samples
                imported_sample <- reactiveVal(NULL) # list of the imported sample names
                imported_bw_data <- reactiveVal(list()) # list of the imported bigwig data
                isCalculating_import <- reactiveVal(FALSE)

                observeEvent(input$Profile_Plot_sample_import, {
                    isCalculating_import(TRUE)

                    # when nothing is selected
                        if(input$Profile_Plot_sample_selection == 'None'){
                            show_alert(title='Error.',text='Please select a dataset.', type='error')
                            Profile_Plot_sample_selection_status("Please select a dataset.")
                            isCalculating_import(FALSE)
                            return()
                        }
                    #

                    # when the selected sample is already imported
                        if(input$Profile_Plot_sample_selection %in% imported_sample()){
                            show_alert(title='Error.',text='The selected dataset is already imported.', type='error')
                            Profile_Plot_sample_selection_status("The selected dataset is already imported.")
                            isCalculating_import(FALSE)
                            return()
                        }
                    #

                    # import the selected sample
                        path <- Dataset()[Dataset()$Dataset == input$Profile_Plot_sample_selection, ]$Path
                        if(!file.exists(path)){
                            show_alert(title='Error.',text='The file does not exist.', type='error')
                            Profile_Plot_sample_selection_status("The file does not exist. Please upload the dataset again.")
                            isCalculating_import(FALSE)
                            return()
                        }
                    #

                    # add the imported sample to the list
                    # Gated behind a CPU/RAM resource check -- see guardHeavyLoad() in
                    # libraries/libraries.R -- since imported tracks accumulate in memory
                    # (removed only when the user explicitly removes them).
                    do_load <- function() {
                        bw_list <- imported_bw_data()
                        bw_list <- append(bw_list, list(import(path))) #  ex. tmp <- import('/home/h023o/ShinyApps/Software/OmicsBridge/00_Expression_data_all/2025/06.24/THP1_LPS.IFNg.0.5h_Rep1.bw')
                        tmp <- imported_sample()
                        tmp <- c(tmp , input$Profile_Plot_sample_selection)
                        imported_sample(tmp)
                        imported_bw_data(bw_list)
                        isCalculating_import(FALSE)
                        Profile_Plot_sample_selection_status(NULL)
                    }
                    on_cancel <- function() {
                        isCalculating_import(FALSE)
                        Profile_Plot_sample_selection_status('Import cancelled.')
                    }
                    guardHeavyLoad(session, "confirm_profile_import", do_load, on_cancel = on_cancel,
                                    what = "this bigWig track", file_paths = path)
                    return()
                })
                heavyLoadConfirmObserver(input, session, "confirm_profile_import")
            #

            # remove selected sample, Profile_Plot_sample_remove
                observeEvent(input$Profile_Plot_sample_remove, {
                    if(length(input$Profile_Plot_imported_sample_table_rows_selected) == 0){
                    show_alert(title='Error.',text='Please select a sample to remove.', type='error')
                    Profile_Plot_sample_selection_status("Please select a sample to remove.")
                    return()
                    }
                    isCalculating_import(TRUE)

                    selected_sample <- imported_sample()[input$Profile_Plot_imported_sample_table_rows_selected]
                    bw_list <- imported_bw_data()
                    # position index
                    delete_index <- which(imported_sample() == selected_sample)
                    bw_list <- bw_list[-delete_index]
                    tmp <- imported_sample()
                    tmp <- tmp[-delete_index]
                    imported_bw_data(bw_list)
                    imported_sample(tmp)
                    isCalculating_import(FALSE)
                    return()
                })
            #

            # Table of imported sample
                output$Profile_Plot_imported_sample_table  <- renderDataTable({
                    if (isCalculating_import()) {
                        tmp <- data.frame(list('Sample.Name'=character(0)), stringsAsFactors = FALSE)
                        return(datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) )
                    }else{
                        if(length(is.null(imported_bw_data())) == 0 || is.null(imported_bw_data())){
                            tmp <- data.frame(list('SampleName'=character(0)), stringsAsFactors = FALSE)
                            datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))
                        }else{
                            tmp <- data.frame(list('SampleName'=imported_sample()), stringsAsFactors = FALSE)
                            datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))
                        }
                    }
                })
            #

    ## Main calculation
        # status
            Profile_Plot_status <- reactiveVal('Please set the input samples and parameters, then click "Generate a plot".')
            output$Profile_Plot_status <- renderText({ Profile_Plot_status() })
        #

        # main calculation
            heatmap_data_list <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            observeEvent(input$Profile_Plot_start, {
                isCalculating(TRUE)

                bw_list <- imported_bw_data()

                # when no dataset is imported
                    if(length(bw_list) == 0 || is.null(bw_list)){
                        show_alert(title='Error.',text='Please import datasets first.', type='error')
                        Profile_Plot_status("Please import datasets first.")
                        isCalculating(FALSE)
                        return()
                    }
                #
                names(bw_list) <- imported_sample()

                # positions to explore
                    if(nchar(input$Profile_Plot_input_coord) == 0){
                        show_alert(title='Error.',text='Please input coordinates.', type='error')
                        Profile_Plot_status("Please input coordinates.")
                        isCalculating(FALSE)
                        return()
                    }
                # the format should be 'chr:start-end'. and they should be line by line without any spaces.
                # if the text input does not follow the format, it will be ignored.

                    genome_position <- unlist(strsplit(input$Profile_Plot_input_coord, split = "\n"))

                # Filter only lines matching 'chr:start-end' format (no spaces)
                    genome_position <- genome_position[grepl("^[^\\s:]+:[0-9]+-[0-9]+$", genome_position)] # ex, genome_position=c('chr1:1000-2000', 'chr2:4000-4000')
                    if(length(genome_position)==0){
                        show_alert(title='Error.',text='Please input coordinates in the format "chr:start-end" (line by line).', type='error')
                        Profile_Plot_status("Please input coordinates in the format 'chr:start-end' (line by line).")
                        isCalculating(FALSE)
                        return()
                    }

                # Parse coordinates and exclude if end < start
                    parsed_coords <- lapply(genome_position, function(x) {
                        parts <- strsplit(x, ":")[[1]]
                        chr <- parts[1]
                        range <- strsplit(parts[2], "-")[[1]]
                        start <- as.numeric(range[1])
                        end <- as.numeric(range[2])
                        if (!is.na(start) && !is.na(end) && end >= start) {
                            list(chr = chr, start = start, end = end)
                        } else {
                            NULL
                        }
                    })
                # Remove NULLs (invalid ranges)
                    parsed_coords <- Filter(Negate(is.null), parsed_coords)
                    if(length(parsed_coords) == 0){
                        show_alert(title='Error.',text='Invalid input. Please check the input.', type='error')
                        Profile_Plot_status("Please check the input. The input should be in the format 'chr:start-end' and the end should be greater than or equal to the start.")
                        isCalculating(FALSE)
                        return()
                    }
                    chr_list <- sapply(parsed_coords, function(x) x$chr)
                    Start_list <- as.numeric(sapply(parsed_coords, function(x) x$start))
                    End_list <- as.numeric(sapply(parsed_coords, function(x) x$end))
                    target_coordinates <- GRanges(seqnames=Rle(chr_list), ranges=IRanges(start=Start_list, end=End_list), Group='test')

                # heatmap_data_list <- normalizeToMatrix( bw_list(), target_coordinates, extend = 2000, value_column = "score", mean_mode = "w0", w = 10 )
                heatmap_data_list_tmp <- lapply(bw_list, function(bw_tmp) {
                    normalizeToMatrix( bw_tmp, target_coordinates, extend = input$Profile_Plot_extend_length, value_column = "score", mean_mode = "w0", w = 10 )
                })
                if(max(unlist(lapply(heatmap_data_list_tmp, function(x) quantile(x,0.98)))) == 0){
                    show_alert(title='Error.',text='The coverage is zero for all the positions. Please check the input coordinates.', type='error')
                    Profile_Plot_status("The coverage is zero for all the positions. Extending the input coordinates may solve this.")
                    heatmap_data_list(NULL)
                    isCalculating(FALSE)
                    return()
                }
                Profile_Plot_status(NULL)
                heatmap_data_list(heatmap_data_list_tmp)
                isCalculating(FALSE)
            })
        #

    ##

    return(list(
        heatmap_data_list = heatmap_data_list,
        isCalculating = isCalculating
    ))
}
