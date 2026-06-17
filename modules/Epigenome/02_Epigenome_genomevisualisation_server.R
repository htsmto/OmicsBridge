# =============================================================================
# Epigenome - Genome Visualisation Server
# File: modules/Epigenome/02_Epigenome_genomevisualisation_server.R
# Purpose: Displays genome-wide signal tracks (bigWig) for selected samples
#          at a user-specified genomic region using the Gviz / karyoploteR package.
# Edit this file when: changing the track types, annotation tracks,
#                       or the genome build (GRCh38 vs hg19).
# Libraries required: see libraries_Epigenome.R
# =============================================================================

Epigenome_genomevisualisation_server <- function(input, output, session, Dataset) {
    ## Inputs and Settings
        # status
            Gviz_selected_dataset_status <- reactiveVal(NULL)
            output$Gviz_selected_dataset_status <- renderText({ Gviz_selected_dataset_status() })
            Gviz_selected_dataset_delete_status <- reactiveVal(NULL)
            output$Gviz_selected_dataset_delete_status <- renderText({ Gviz_selected_dataset_delete_status() })
        #

        # dataset select
            output$Gviz_data_select <- renderUI({
                df_tmp <- Dataset()
                if(length(input$Gviz_data_type)==0){
                    return(NULL)
                }
                else if(input$Gviz_data_type == 'BigWig'){ # 'BigWig', 'BAM'
                    df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
                }else if(input$Gviz_data_type == 'BAM'){
                    df_tmp <- df_tmp[df_tmp$Data.Class == 'F',]
                }
                selectInput(session$ns('Gviz_data_select'), 'Select a dataset to see in Gviz', c('None'='None', unique(df_tmp$Dataset)) )
            })
        #

        # Add the selected data to Gviz_selected_dataset and show the list in output$Gviz_selected_dataset as a table
            Gviz_selected_dataset <- reactiveVal(c())
            Gviz_selected_dataset_type <- reactiveVal(c())
            observeEvent(input$Gviz_data_add, {
                if(length(input$Gviz_data_select) == 0 || input$Gviz_data_select == 'None'){
                    Gviz_selected_dataset_status('Please select a dataset.')
                    return(NULL)
                }
                tmp <- Gviz_selected_dataset()
                if(input$Gviz_data_select %in% tmp) {
                    Gviz_selected_dataset_status('The selected dataset is already added.')
                    return(NULL)
                }
                tmp <- c(tmp, input$Gviz_data_select)
                Gviz_selected_dataset(tmp)
                Gviz_selected_dataset_type(c(Gviz_selected_dataset_type(), input$Gviz_data_type))
                Gviz_selected_dataset_status(NULL)
            })
        #
            
        # show as a table
            output$Gviz_selected_dataset <- renderDataTable({
                if(length(Gviz_selected_dataset()) == 0){
                    tmp <- data.frame('Dataset'=character(0), stringsAsFactors = FALSE)
                    datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))
                }else{
                    tmp <- data.frame('Dataset'=Gviz_selected_dataset(), 'Type'=Gviz_selected_dataset_type(), stringsAsFactors = FALSE)
                    datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))
                }
            })
        #

        # delete the selected dataset from the list
            observeEvent(input$Gviz_data_delete, {
                if(length(input$Gviz_selected_dataset_rows_selected) == 0){
                    Gviz_selected_dataset_delete_status('Please select a dataset to remove.')
                    return(NULL)
                }
                tmp <- Gviz_selected_dataset()
                tmp_type <- Gviz_selected_dataset_type()
                selected_row <- input$Gviz_selected_dataset_rows_selected
                tmp <- tmp[-selected_row]
                tmp_type <- tmp_type[-selected_row]
                Gviz_selected_dataset(tmp)
                Gviz_selected_dataset_type(tmp_type)
                Gviz_selected_dataset_delete_status(NULL)
            })
        #

    ##

    ## Plot
        # change the cyto based on the Gviz_genome_selection. hg38 or hg19
            cyto <- reactive({
                if(input$Gviz_genome_selection == 'hg38'){
                    read.table("data/cytoBand_hg38.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
                }else if(input$Gviz_genome_selection == 'hg19'){
                    read.table("data/cytoBand_hg19.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
                }else{
                    return(NULL)
                }
            })
        #

        # status
            Gviz_plot_status <- reactiveVal("Please select the input datasets and set the chromosome position, and click the start button.")
            output$Gviz_plot_status <- renderText({ Gviz_plot_status() })
        #

        # main plot, Calculation
            options(ucscChromosomeNames=FALSE) 
            Gviz_Tracks <- reactiveVal(NULL)
            Gviz_Track_sizes <- reactiveVal(c())
            Gviz_params <- reactiveVal(NULL)
            isCalculating_Gviz <- reactiveVal(FALSE)

            observeEvent(input$Gviz_plot_start, {
                isCalculating_Gviz(TRUE)

                # if the chromosome position is invalid
                    if(length(input$Gviz_chromosome_pos)==0 || input$Gviz_chromosome_pos == ''){
                        Gviz_plot_status('Please input the chromosome position in the format "chrN:start-end".')
                        Gviz_Tracks(NULL)
                        isCalculating_Gviz(FALSE)
                        return(NULL)
                    }
                #

                # chromosome position parsing
                Gviz_chr <- strsplit(input$Gviz_chromosome_pos, ':')[[1]][1] # The format is "chrN:start-end". Let's break this to chrN, start, and end.
                Gviz_start <- as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][1])
                Gviz_end <- as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][2])

                # if the chromosome names and position is invalid
                    if(is.na(Gviz_start) || is.na(Gviz_end)){
                        Gviz_plot_status('Please input the chromosome position in the format "chrN:start-end".')
                        Gviz_Tracks(NULL)
                        isCalculating_Gviz(FALSE)
                        return(NULL)
                    }
                    if(Gviz_start >= Gviz_end){
                        Gviz_plot_status('The start position should be less than the end position.')
                        Gviz_Tracks(NULL)
                        isCalculating_Gviz(FALSE)
                        return(NULL)
                    }
                    if(!Gviz_chr %in% cyto()$chrom){
                        Gviz_plot_status('The chromosome name is not valid. Please check the chromosome name.')
                        Gviz_Tracks(NULL)
                        isCalculating_Gviz(FALSE)
                        return(NULL)
                    }
                #
                Gviz_plot_status(NULL)

                # genome and chromosome
                gen=input$Gviz_genome_selection
                chr=Gviz_chr

                # base tracks
                itrack <- Gviz::IdeogramTrack(genome = gen, chromosome = chr, bands = cyto(), fontsize=5)
                gtrack <- Gviz::GenomeAxisTrack(fontsize=5)
                grtrack <- Gviz::GeneRegionTrack(customegeneModels, genome = gen, chromosome = chr, name = "Refseq", transcriptAnnotation = "gene", cex = 0.4, fontsize=5,fontsize.group=2)

                # refseq colour option
                scheme <- Gviz::getScheme()
                scheme$GeneRegionTrack$fill <- input$Gviz_plot_refseq_col
                scheme$GeneRegionTrack$col <- NULL
                scheme$GeneRegionTrack$fontsize <- 2
                Gviz::addScheme(scheme, "myScheme")
                options(Gviz.scheme = "myScheme")

                ## DataTrack objects:
                DataTrack_list <- list()
                DataTrack_list[[1]] <- itrack
                DataTrack_list[[2]] <- gtrack
                Gviz_Track_sizes_tmp <- c(0.1, 0.1)
                if(length(Gviz_selected_dataset()) >= 1){
                    for (i in seq_along(Gviz_selected_dataset())) {
                        dataset <- Gviz_selected_dataset()[i]
                        type <- Gviz_selected_dataset_type()[i]
                        path <- Dataset()[Dataset()$Dataset == dataset, ]$Path
                        if(type == 'BigWig'){
                            if(input$Gviz_plot_ylim_bw){
                                DataTrack_list[[i+2]] <-  Gviz::DataTrack(range = path, genome = gen, type = "l",  chromosome = chr, name = gsub("(.{11})", "\\1\n", dataset), fill.mountain=c(input$Gviz_plot_bw_col, input$Gviz_plot_bw_col), col.mountain=c(input$Gviz_plot_bw_col, input$Gviz_plot_bw_col), col=input$Gviz_plot_bw_col, input$Gviz_plot_bw_col, fontsize=6, ylim=c(0, as.numeric(input$Gviz_plot_ylim_bw_max)))
                            }else{
                                DataTrack_list[[i+2]] <-  Gviz::DataTrack(range = path, genome = gen, type = "l",  chromosome = chr, name = gsub("(.{11})", "\\1\n", dataset), fill.mountain=c(input$Gviz_plot_bw_col, input$Gviz_plot_bw_col), col.mountain=c(input$Gviz_plot_bw_col, input$Gviz_plot_bw_col), col=input$Gviz_plot_bw_col, fontsize=6)
                            }
                            Gviz_Track_sizes_tmp <- c(Gviz_Track_sizes_tmp, as.numeric(input$Gviz_plot_height_bw)/100)
                        }else if(type == 'BAM'){
                            options(ucscChromosomeNames=FALSE)
                            if(input$Gviz_plot_ylim_bam){
                                DataTrack_list[[i+2]] <- Gviz::AlignmentsTrack(path, isPaired = TRUE, type= "coverage", genome = gen, chromosome = chr, name = gsub("(.{11})", "\\1\n", dataset), fill = input$Gviz_plot_bam_col, col = input$Gviz_plot_bam_col, coverageHeight=1, fontsize=6, ylim=c(0, as.numeric(input$Gviz_plot_ylim_bam_max)))
                            }else{
                                DataTrack_list[[i+2]] <- Gviz::AlignmentsTrack(path, isPaired = TRUE, type= "coverage", genome = gen, chromosome = chr, name = gsub("(.{11})", "\\1\n", dataset), fill = input$Gviz_plot_bam_col, col = input$Gviz_plot_bam_col, coverageHeight=1, fontsize=6)
                            }
                            Gviz_Track_sizes_tmp <- c(Gviz_Track_sizes_tmp, as.numeric(input$Gviz_plot_height_bam)/100)
                        }
                    }
                }
                DataTrack_list[[length(DataTrack_list) + 1]] <- grtrack
                Gviz_Track_sizes_tmp <- c(Gviz_Track_sizes_tmp, as.numeric(input$Gviz_plot_height_ref)/100)

                ### Gviz tracks
                Gviz_Tracks(DataTrack_list)
                Gviz_Track_sizes(Gviz_Track_sizes_tmp)
                Gviz_params(list(genome = gen, chromosome = chr, from = Gviz_start, to = Gviz_end))
                isCalculating_Gviz(FALSE)
                return(NULL)
            })
        #


        # plot
            output$Gviz_plot <- renderPlot({
                if(isCalculating_Gviz()){
                    return(NULL)
                }
                if(length(Gviz_Tracks()) == 0 || is.null(Gviz_Tracks())){
                    return(ggplot())
                }else(
                    Gviz::plotTracks(Gviz_Tracks(), from = Gviz_params()$from, to = Gviz_params()$to, chromosome=Gviz_params()$chromosome, sizes = Gviz_Track_sizes())
                )
            }, width = reactive(input$Gviz_fig.width), height = reactive(input$Gviz_fig.height), res=300)
        # 

    ##
}