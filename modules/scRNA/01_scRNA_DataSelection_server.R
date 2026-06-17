# =============================================================================
# scRNA - Dataset Selection Server
# File: modules/scRNA/01_scRNA_DataSelection_server.R
# Purpose: Reads Database.tsv and populates the scRNA dataset selector with
#          only Seurat .rds datasets. Returns the selected dataset's file path
#          for use by the UMAP and Feature sub-servers.
# Edit this file when: changing dataset filtering criteria (e.g. by data type
#                       tag), or modifying the dataset selector UI.
# =============================================================================

scRNA_DataSelection_server  <- function(input, output, session, Dataset) {
    ## dataset selection
        # load all dataset table
            # Dataset <- data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE))

        # dataset selection UI
            output$scRNA_data_select <- renderUI({ 
                selectInput(session$ns('scRNA_data_select'), 'Select a scRNA data', c('None'='None', Dataset[Dataset$Data.Class == 'C',]$Dataset)) 
            })

    ##

    ## dataset detail
        # initial status
            detail_message <- reactiveVal('Please select a dataset.')

        # when dataset selection changes, update the detail message
            observe({
                if(!is.null(input$scRNA_data_select) && input$scRNA_data_select != 'None'){
                    detail_message(paste0(
                        'Data.from: ', as.character(Dataset[Dataset$Dataset == input$scRNA_data_select, ]$Data.from), '\n', 
                        'Experiment: ', as.character(Dataset[Dataset$Dataset == input$scRNA_data_select, ]$Experiment), '\n', 
                        'When: ' , as.character(Dataset[Dataset$Dataset == input$scRNA_data_select, ]$When), '\n', 
                        'Description: ' , as.character(Dataset[Dataset$Dataset == input$scRNA_data_select, ]$Description), '\n'
                    ))
                }else{
                    detail_message('Please select a dataset.')
                }
            })

        # render the detail message
            output$scRNA_data_Dataset_detail <- renderText({ detail_message() })

    ##


}