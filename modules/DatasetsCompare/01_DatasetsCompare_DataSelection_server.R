# =============================================================================
# DatasetsCompare - Dataset Selection Server
# File: modules/DatasetsCompare/01_DatasetsCompare_DataSelection_server.R
# Purpose: Renders a multi-select widget populated from Database.tsv and
#          returns the selected rows as a reactive data frame passed to the
#          overlap and comparison sub-servers.
# Edit this file when: changing the number of selectable datasets, adding
#                       filtering by data class, or modifying the selection UI.
# =============================================================================

DatasetsCompare_DataSelection_server <- function(input, output, session){
    ## status / initial settings
        # status
            Compare_dataset_selection_status <- reactiveVal(NULL)
            output$Compare_dataset_selection_status <- renderText({ Compare_dataset_selection_status() })

        # 

        # dataset
            # load the database
                Dataset <- reactiveVal(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
                filtered_Dataset <- reactiveVal(NULL)
            #
        
            # reload
                observeEvent(input$Reload_your_databse, {
                    Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
                })
            #
        #
                    
    ##

    ## UI
        # data type selection
            output$choose_data_type <- renderUI({
                df_tmp <- Dataset()
                selectInput(session$ns('choose_data_type'), 'Data type', c('None'='None', unique(df_tmp[df_tmp$Data.Class == 'B',]$Data.type)))
            })

        #

        # selectinon filtering
            # data from who
                output$Compare_dataset_filtering_Data_from <- renderUI({
                    data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
                    tmp <- data_tmp$Data.from
                    selectInput(session$ns('Compare_dataset_filtering_Data_from'), 'Data from', c('None'= 'None', tmp))
                })

            #

            # data from which experiment
                output$Compare_dataset_filtering_Experiment <- renderUI({
                    data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
                    if(length(input$Compare_dataset_filtering_Data_from)!= 0){
                        if(input$Compare_dataset_filtering_Data_from != 'None'){ data_tmp <- data_tmp[data_tmp$Data.from == input$Compare_dataset_filtering_Data_from,] }
                    }
                    tmp <- data_tmp$Experiment
                    selectInput(session$ns('Compare_dataset_filtering_Experiment'), 'Experiment', c('None'= 'None', tmp))
                })

            #

        # 
    
    ## data table
        # list of the all datasets from which you select the dataset
            output$all_dataset <- DT::renderDataTable({ 
                # data_table_tmp <- Dataset()

                # when 'data type' is not selected, return an empty table and show a message to ask users to select the data type
                if(length(input$choose_data_type) == 0 || input$choose_data_type == 'None'){
                    filtered_Dataset(NULL)
                    Compare_dataset_selection_status('Please select the data type to show the datasets for comparison.')
                    return(datatable(data.frame()))
                } else {
                    data_table_tmp <- Dataset()
                    data_table_tmp <- data_table_tmp[data_table_tmp$Data.type == input$choose_data_type, ] 
                    Compare_dataset_selection_status(paste0('Showing the datasets with data type: ', input$choose_data_type))

                    # when 'data from' is set
                    if(length(input$Compare_dataset_filtering_Data_from) != 0 && input$Compare_dataset_filtering_Data_from!= 'None'){ 
                        data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] 
                    }

                    # when 'Experiment' is set
                    if(length(input$Compare_dataset_filtering_Experiment) != 0 && input$Compare_dataset_filtering_Experiment != 'None'){ 
                        data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] 
                    }

                    # return the table
                    filtered_Dataset(data_table_tmp)
                    datatable(data_table_tmp[,c( "Dataset", "Data.type", "Experiment",  "Data.from", "When", "Description")] , 
                        selection='none', extensions=c('Select', 'Buttons'), rownames=F,
                        options = list( select=list(style="multi", items='row'), 
                        scrollX = TRUE, pageLength = 10, 
                        dom='Blfrtip', rowId=0, buttons=c('selectAll', 'selectNone') )
                    )

                    
                }


            },server = FALSE)

        #

        # return the selected datasets
            selected_datasets_table <- reactiveVal(NULL)
            observe({
                # when nothing is selected in the table
                if(length(input$all_dataset_rows_selected) == 0 || is.null(input$all_dataset_rows_selected) || length(input$all_dataset_rows_selected) == 0){
                    selected_datasets_table(NULL)
                } else {
                    selected_datasets_table(filtered_Dataset()[input$all_dataset_rows_selected, ])
                }
            })
            return(selected_datasets_table)
        #

}