# =============================================================================
# Epigenome - IGV Browser Server
# File: modules/Epigenome/03_Epigenome_igv_server.R
# Purpose: Embeds an igvShiny browser panel. Loads bigWig/BAM tracks for
#          the selected dataset and navigates to user-specified loci.
# Edit this file when: changing which track formats are supported,
#                       or the default locus shown on load.
# Libraries required: igvShiny (loaded via libraries_Epigenome.R)
# =============================================================================

Epigenome_igv_server <- function(input, output, session, Dataset){
    ## data selection for IGV
        # data from who
            output$igv_data_DataFrom <- renderUI({  
                if(length(Dataset()) == 0 || length(Dataset()[Dataset()$Data.Class == 'D',]$Data.from) == 0){
                    selectInput(session$ns('igv_data_DataFrom'), 'Data from', c('None'='None')) 
                }else{
                    selectInput(session$ns('igv_data_DataFrom'), 'Data from', c('None'='None', Dataset()[Dataset()$Data.Class == 'D',]$Data.from)) 
                }
            })
        #

        # data from which experiment
            output$igv_data_Experiment <- renderUI({  
                if(length(Dataset()) == 0 || length(Dataset()[Dataset()$Data.Class == 'D',]$Data.from) == 0){
                    selectInput(session$ns('igv_data_Experiment'), 'Experiment', c('None'='None'))
                }else{
                    tmp <- Dataset()[Dataset()$Data.Class == 'D',]
                    if(length(input$igv_data_DataFrom) == 0 || input$igv_data_DataFrom == 'None'){
                        selectInput(session$ns('igv_data_Experiment'), 'Experiment', c('None'='None'))   
                    }else if(input$igv_data_DataFrom != 'None'){ 
                        tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] 
                        selectInput(session$ns('igv_data_Experiment'), 'Experiment', c('None'='None', tmp$Experiment)) 
                    }

                }
            })
        #

        # data selection
            output$igv_data_select <- renderUI({ 
                if(length(Dataset()) == 0 || length(Dataset()[Dataset()$Data.Class == 'D',]$Data.from) == 0){
                    return(selectInput(session$ns('igv_data_select'), 'Select dataset to see in IGV', c('None'='None'))) 
                }else{
                    tmp <- Dataset()[Dataset()$Data.Class == 'D',]
                    if(!is.null(input$igv_data_DataFrom) && input$igv_data_DataFrom != 'None'){ tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] }
                    if(!is.null(input$igv_data_Experiment) && input$igv_data_Experiment != 'None'){ tmp <-tmp[tmp$Experiment == input$igv_data_Experiment,] }
                    selectInput(session$ns('igv_data_select'), 'Select dataset to see in IGV', c('None'='None', tmp$Dataset)) 
                }
            })
        #

        # show the detail
            igv_Dataset_detail <- reactiveVal('Please select a dataset.')
            output$igv_Dataset_detail <- renderText({ igv_Dataset_detail() })

            observe({
                if(length(Dataset()) == 0 || length(Dataset()[Dataset()$Data.Class == 'D',]$Data.from) == 0){
                    igv_Dataset_detail('Please select a dataset.')
                }else{
                    df_tmp <- Dataset()
                    if(!is.null(input$igv_data_select) && input$igv_data_select != 'None'){
                        igv_Dataset_detail(paste0('Data.from: ', as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Data.from), '\n', 
                            'Experiment: ', as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Experiment), '\n', 
                            'Data.type: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Data.type), '\n', 
                            'When: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$When), '\n', 
                            'Description: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Description), '\n'
                            ))
                    }else{
                        igv_Dataset_detail('Please select a dataset.')
                    }
                }

            })
        #

        # change the header of the bed file
            bed_data <- reactive({ 
                if(is.null(input$igv_data_select) || input$igv_data_select == 'None'){
                    return(NULL)
                }
                path <- Dataset()[Dataset()$Dataset == input$igv_data_select, ]$Path
                if(!file.exists(path)){
                    show_alert(title='Error.',text='The file does not exist.', type='error')
                    igv_Dataset_detail("The file does not exist. Please upload the dataset again.")
                    return(NULL)
                }
                tmp <- read.table(path, sep='\t',check.names = FALSE) # head(bed_data)
                colnames(tmp)[1] <- 'chrom'
                colnames(tmp)[2] <- 'start'
                colnames(tmp)[3] <- 'end'
                colnames(tmp)[5] <- 'score'
                return(tmp)
            })
        #
        
    ##

    #### start igv
      
        # igv initiation
            output$igv <- renderIgvShiny({
                options <- parseAndValidateGenomeSpec(genomeName=input$igv_gneome_selection)
                igvShiny(options)  # Initialize IGV
            })
        #

        # add bed file to view
            observeEvent(input$igv_data_add, {
                if(is.null(input$igv_data_select) || input$igv_data_select == 'None'){
                    show_alert(title='Error.',text='Please select a dataset to view in IGV.', type='error')
                    igv_Dataset_detail('Please select a dataset to view in IGV.')
                    return()
                }
                loadBedTrack(session, id=session$ns("igv"), trackName=input$igv_data_select, tbl=bed_data())
            })
        #

    ##
}