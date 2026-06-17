# =============================================================================
# Clinical - Dataset Selection Server
# File: modules/Clinical/01_clinical_DataSelection_server.R
# Purpose: Reads Clinical_data_database.tsv to build the dataset selector and
#          returns the selected dataset's file paths (expression, survival,
#          metadata, mutation) as a reactive list consumed by ViewData.
# Edit this file when: changing how clinical dataset paths are resolved, or
#                       adding new file-type columns to the database TSV.
# =============================================================================

clinical_DataSelection_server <- function(input, output, session) {
    ## initial setting
        # database load
            Clinical_dataset <- reactiveVal({data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE))})
        #

        # reload database
            observeEvent(input$Clinical_data_reload, {
                Clinical_dataset(data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE)))
            })
        #   

        # status
            Clinical_Dataset_detail <- reactiveVal(NULL)
            output$Clinical_Dataset_detail <- renderText({ Clinical_Dataset_detail()})
    ##

    ## dataset selection
        # UI
            output$Clinical_data_select <- renderUI({ 
                selectInput(session$ns('Clinical_data_select'), 'Select a clinical data', c('None'='None', Clinical_dataset()$Database.Name)) 
            })

        #

        # Once a dataset is selected, show the dataset detail
        # and export the file path for downstream analysis
            # Database.Name	Description	Expression_path	Survival_path	Meta_path	added.when	Mutation_path
            database_name <- reactiveVal(NULL)
            detail_info <- reactiveVal(NULL)
            Ex_path <- reactiveVal(NULL)
            Surv_path <- reactiveVal(NULL)
            Meta_path <- reactiveVal(NULL)
            Mut_path <- reactiveVal(NULL)
            observe({
                # when nothing is selected, do nothing
                if(length(input$Clinical_data_select) == 0 || input$Clinical_data_select == 'None'){
                    # show a message
                    Clinical_Dataset_detail('Please select a clinical dataset.') 
                    
                    # set all the path to NULL
                    database_name(NULL)
                    detail_info(NULL)
                    Ex_path(NULL)
                    Surv_path(NULL)
                    Meta_path(NULL)
                    Mut_path(NULL)
                    
                    return(NULL)
                }

                # once a dataset is selected, show the dataset detail
                database_name(input$Clinical_data_select)
                detail_info(Clinical_dataset()[Clinical_dataset()$Database.Name == input$Clinical_data_select, 'Description'])
                Ex_path(Clinical_dataset()[Clinical_dataset()$Database.Name == input$Clinical_data_select, 'Expression_path'])
                Surv_path(Clinical_dataset()[Clinical_dataset()$Database.Name == input$Clinical_data_select, 'Survival_path'])
                Meta_path(Clinical_dataset()[Clinical_dataset()$Database.Name == input$Clinical_data_select, 'Meta_path'])
                Mut_path(Clinical_dataset()[Clinical_dataset()$Database.Name == input$Clinical_data_select, 'Mutation_path'])

                # show the detail
                Clinical_Dataset_detail(paste0('Dataset: ', database_name(), '\nDescription: ', detail_info()))
            })

        # 

        # Return the paths list
            return(list(
                Name = database_name,
                Ex_path = Ex_path,
                Surv_path = Surv_path,
                Meta_path = Meta_path,
                Mut_path = Mut_path
            ))
        
        #

    ## 
}