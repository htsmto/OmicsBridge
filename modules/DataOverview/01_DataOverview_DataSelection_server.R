# =============================================================================
# DataOverview - Dataset Selection Server
# File: modules/DataOverview/01_DataOverview_DataSelection_server.R
# Purpose: Populates the dataset selector from Database.tsv and returns the
#          user's selection (dataset name + data class) as a reactive value
#          consumed by all downstream DataOverview sub-servers.
# Edit this file when: changing how the dataset list is built, adding
#                       dataset filtering, or modifying the returned data class.
# =============================================================================

dataoverview_dataselection_Server <- function(input, output, session) {
    ## initial settings
        Dataset <- reactiveVal({data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE))})
        details <- reactiveVal(NULL)
        filter_datasets <- reactiveVal(Dataset)

        # reload database
            observeEvent(input$reload_database, {
                Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
            })
        #   

    ## Dataset loading and filtering
        # three Filtering UI
            output$Seuqenced_by <- renderUI({
                selectInput(session$ns('Seuqenced_by'), 'Sequenced by', c('None'='None', unique(Dataset()$Data.from)) )
            })

            output$Experiments <- renderUI({
                if(length(input$Seuqenced_by) > 0 && input$Seuqenced_by != 'None'){
                    filtered_experiments <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by,]$Experiment)
                    selectInput(session$ns('Experiments'), 'Experiments', c('None'='None', filtered_experiments), selected = 'None') 
                } else {
                    selectInput(session$ns('Experiments'), 'Experiments', c('None'='None', unique(Dataset()$Experiment)), selected = 'None') 
                } 
            })

            output$Data_type <- renderUI({
                if(length(input$Seuqenced_by) > 0 && input$Seuqenced_by != 'None' && length(input$Experiments) > 0 && input$Experiments != 'None'){
                    filtered_data_types <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by & Dataset()$Experiment == input$Experiments,]$Data.type)
                    selectInput(session$ns('Data_type'), 'Data type', c('None'='None', filtered_data_types), selected = 'None') 
                } else if(length(input$Seuqenced_by) > 0 && input$Seuqenced_by != 'None'){
                    filtered_data_types <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by,]$Data.type)
                    selectInput(session$ns('Data_type'), 'Data type', c('None'='None', filtered_data_types), selected = 'None') 
                } else if(length(input$Experiments) > 0 && input$Experiments != 'None'){
                    filtered_data_types <- unique(Dataset()[Dataset()$Experiment == input$Experiments,]$Data.type)
                    selectInput(session$ns('Data_type'), 'Data type', c('None'='None', filtered_data_types), selected = 'None') 
                } else {
                    selectInput(session$ns('Data_type'), 'Data type', c('None'='None', unique(Dataset()$Data.type)), selected = 'None') 
                }
            })

        # Filter the dataset
            observe({
                df_tmp <- Dataset()

                # extract only the datasets with Data.Class of 'A' or 'B'
                df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
                
                # filtering
                if(length(input$Data_type) > 0 && input$Data_type != 'None') { df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}
                if(length(input$Seuqenced_by) > 0 && input$Seuqenced_by != 'None') { df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}
                if(length(input$Experiments) > 0 && input$Experiments != 'None') { df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}
                
                # update the filtered dataset
                filter_datasets(df_tmp)
            })


    ## Dataset selection and show the detail of selected dataset
        # Dataset selection
            output$Dataset_select <- renderUI({
                selectInput(session$ns('Dataset_select'), 'Dataset select', c('None'='None', unique(filter_datasets()$Dataset)) )
            })

        # Dataset detail
            observe({
                # when no dataset is selected, show nothing
                if(length(input$Dataset_select) == 0 || input$Dataset_select == 'None'){
                    details('Please select a dataset.')
                    return()
                }

                # once dataset is selected, show the detail of the dataset
                details(paste0(
                    'Dataset Name: ', as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Dataset), '\n', 
                    'Data.from: ', as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Data.from), '\n', 
                    'Experiment: ', as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Experiment), '\n', 
                    'Data.type: ' , as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Data.type), '\n', 
                    'When: ' , as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$When), '\n', 
                    'Control.group: ' , as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Control.group), '\n',
                    'Treatment.group: ' , as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Treatment.group), '\n',
                    'Description: ' , as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Description), '\n'
                ))
                return()
            })

        # show the dataset detail
            output$Dataset_detail <- renderText({
                details()
            })

        # output the data.class for the conditional panel in the overview and analysis section
            Dataset_dataclass <- reactiveVal(NULL)
            observe({
                if(length(input$Dataset_select) == 0 || input$Dataset_select == 'None'){
                    Dataset_dataclass("None")
                } else {
                    Dataset_dataclass(as.character(Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Data.Class))
                }
            })

            # outputOptions(output, "Dataset_dataclass", suspendWhenHidden = FALSE)
    
        # return
            return(Dataset_dataclass)

}
