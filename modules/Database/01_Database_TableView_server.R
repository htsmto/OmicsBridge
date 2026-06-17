# =============================================================================
# Database - Table View Server
# File: modules/Database/01_Database_TableView_server.R
# Purpose: Loads and displays the master dataset registry (Database.tsv) as
#          an interactive DataTable so users can browse available cohorts.
# Edit this file when: changing the table columns shown, adding search/filter
#                       options, or modifying how the database TSV is read.
# =============================================================================

database_tableview_Server <- function(input, output, session) {

    ## Status
        status <- reactiveVal("")
        edit_flag <- reactiveVal(FALSE)

    ## show the satsus text
        output$status <- renderText(status())

    ## load the full database
        Dataset <- reactiveVal(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
        Dataset_initial <- reactiveVal(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))

    ## Reload the Dataset
        observeEvent(input$Reload, {
            Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
            Dataset_initial(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
        })

    ## filtering options for the dataset table
        # 'Data.from' filter
        output$Seuqenced_by_filter <- renderUI({ 
            selectInput(session$ns('Seuqenced_by_filter'), 'Data from', c(All= 'None', unique(Dataset()$Data.from)), selected = 'None') 
        })

        # 'Experiment' filter
        output$Experiment_filter <- renderUI({ 
            # if 'Seuqenced_by_filter' is selected, only show the experiment options related to the selected data source
            if(length(input$Seuqenced_by_filter) > 0 && input$Seuqenced_by_filter != 'None'){
                filtered_experiments <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by_filter,]$Experiment)
                selectInput(session$ns('Experiment_filter'), 'Experiment', c(All= 'None', filtered_experiments), selected = 'None') 
            } else {
                selectInput(session$ns('Experiment_filter'), 'Experiment', c(All= 'None', unique(Dataset()$Experiment)), selected = 'None') 
            }
        })
        
        # 'Data.Class' filter
        output$Data_type_filter <- renderUI({
            #  if 'Seuqenced_by_filter' or 'Experiment_filter' or both is selected, only show the experiment options related to the selected data source
            if(length(input$Seuqenced_by_filter) > 0 && input$Seuqenced_by_filter != 'None' && length(input$Experiment_filter) > 0 && input$Experiment_filter != 'None'){
                filtered_data_types <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by_filter & Dataset()$Experiment == input$Experiment_filter,]$Data.type)
                selectInput(session$ns('Data_type_filter'), 'Data type', c(All= 'None', filtered_data_types), selected = 'None') 
            } else if(length(input$Seuqenced_by_filter) > 0 && input$Seuqenced_by_filter != 'None'){
                filtered_data_types <- unique(Dataset()[Dataset()$Data.from == input$Seuqenced_by_filter,]$Data.type)
                selectInput(session$ns('Data_type_filter'), 'Data type', c(All= 'None', filtered_data_types), selected = 'None') 
            } else if(length(input$Experiment_filter) > 0 && input$Experiment_filter != 'None'){
                filtered_data_types <- unique(Dataset()[Dataset()$Experiment == input$Experiment_filter,]$Data.type)
                selectInput(session$ns('Data_type_filter'), 'Data type', c(All= 'None', filtered_data_types), selected = 'None') 
            } else {
                selectInput(session$ns('Data_type_filter'), 'Data type', c(All= 'None', unique(Dataset()$Data.type)), selected = 'None') 
            }
        })
            # outputOptions(output, "Seuqenced_by_filter", suspendWhenHidden=FALSE)

    ## filter the database table if the user select any filter options
        Filtered_dataset <- reactiveVal()
        observe({
            # sort the dataset and select the columns
            data_table_tmp <- Dataset()[order(Dataset()$Added.When, decreasing =T),]
            data_table_tmp <- data_table_tmp[,c( "Dataset", "Data.type", "CellLine", "Data.from", "When", 'Experiment', 'Control.group', 'Treatment.group', "Data.Class", "Description")] 

            # Apply filters based on user input
            if(length(input$Data_type_filter) > 0 && input$Data_type_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.type == input$Data_type_filter, ] }
            if(length(input$Seuqenced_by_filter) > 0 && input$Seuqenced_by_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Seuqenced_by_filter,] }
            if(length(input$Experiment_filter) > 0 && input$Experiment_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Experiment_filter,] }

            # change the satus text. If there is no filter allied, tell the user the total number of datasets. If there is filter applied, tell the user how many datasets are shown and how many are in total.
            # if the edit_flag is true, do not show the dataset info.
            if(!edit_flag()){
                if(dim(data_table_tmp)[1] == dim(Dataset())[1]){
                    status(paste0("Showing all datasets. Total ", dim(Dataset())[1], " datasets."))
                } else {
                    status(paste0("Showing ", dim(data_table_tmp)[1], " datasets after filtering. Total ", dim(Dataset())[1], " datasets in the database."))
                }   
            }

            # set the filtered dataset to the reactive value
            Filtered_dataset(data_table_tmp)
        })


    ## Display the dataset in a table
        output$DataBaseTable <- DT::renderDataTable({
            # Render the datatable with the filtered data
            datatable(Filtered_dataset(), 
                selection='none', extensions=c('Select'), rownames=F,
                options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0), 
                editable= list(target = 'cell', disable = list(columns = c(0))) # you cannot edit the dataset name (the first column)
            ) 
        },server = FALSE)

    ## Edit the dataset table and save the changes to the original dataset
        observeEvent(input$DataBaseTable_cell_edit,{
            # detect the edited cell 
            info <- input$DataBaseTable_cell_edit
            edit_flag(TRUE)
            status(paste0("You edited a cell.", "\nOld value: ", Filtered_dataset()[info$row, info$col+1], "\nNew value: ", info$value, "\nPress 'Save changes' to save the edit."))

            # update 'Filtered_dataset' 
            tmp <- Filtered_dataset()
            tmp[info$row, info$col+1] <- info$value
            Filtered_dataset(tmp)

            # also, update the original 'Dataset' by getting the dataset name of the edited row, and update the corresponding row in 'Dataset'
            tmp <- Dataset()
            dataset_name <- Filtered_dataset()[info$row, "Dataset"]
            tmp[tmp$Dataset == dataset_name, info$col+1] <- info$value
            Dataset(tmp)
        })

    ## Save the edited dataset to the original dataset and write to the tsv file
        # confirmation button
        observeEvent(input$save_dt,{
            if(!edit_flag()){
                show_alert(title='No changes detected', text='You have not made any changes to save.', type='info')
                return()
            }
            confirmSweetAlert(
                session = session,
                inputId = session$ns("confirm_save_dt"),
                title = "Are you sure you want to save the changes?",
                text = "This action cannot be undone.",
                btn_labels = c("Cancel", "Save"), # left=False, right=true, so the order of the buttons is Cancel, Save
                btn_colors = c("#5b5d6e", "#bc2929")
            ) 
        })

        # save the changes if the user confirm to save
        observeEvent(input$confirm_save_dt, {
            if(input$confirm_save_dt){
                Dataset_initial(Dataset())
                write.table(Dataset(), 'data/Database.tsv', row.names=F, sep='\t', quote=F)
                show_alert(title='Success!', text='The changes are saved.', type='success')
                status('All changes are saved.')
                edit_flag(FALSE)
            }
        })

    ## Reset the edits and show the original dataset
        # reset the edits and show the original dataset
        observeEvent(input$reset_edit, {
            if(!edit_flag()){
                show_alert(title='No changes detected', text='You have not made any changes to reset.', type='info')
                return()
            }
            confirmSweetAlert(
                session = session,
                inputId = session$ns("confirm_reset_dt"),
                title = "Are you sure you want to reset the edits?",
                text = "This action cannot be undone.",
                btn_labels = c("Cancel", "Reset"), # left=False, right=true, so the order of the buttons is Cancel, Reset
                btn_colors = c("#5b5d6e", "#1c7f42")
            ) 
        })

        # reset the edits if the user confirm to reset
        observeEvent(input$confirm_reset_dt, {
            if(input$confirm_reset_dt){
                Dataset(Dataset_initial())
                show_alert(title='Success!', text='All edits are reset.', type='success')
                status('All edits are reset.')
                edit_flag(FALSE)
            }
        })

    ## Delete selected datasets
        # Confirm the deletion. Show which dataset will be deleted and ask the user to confirm the deletion.
        observeEvent(input$delete_row, {
            selected_row <- input$DataBaseTable_rows_selected
            if(length(selected_row)==0){
                show_alert(title='Error.',text='No row selected!', type='error')
                return()
            }
            datasets_to_delete <- Filtered_dataset()[selected_row, "Dataset"]
            confirmSweetAlert(
                session = session,
                inputId = session$ns("confirm_delete_row"),
                title = "Are you sure you want to delete the selected dataset(s)?",
                text = paste0("The following dataset(s) will be deleted:\n", paste('"', datasets_to_delete, '"', collapse = "\n"), "\nThis action cannot be undone."),
                btn_labels = c("Cancel", "Delete"), # left=False, right=true, so the order of the buttons is Cancel, Delete
                btn_colors = c("#5b5d6e", "#1C07A6")
            )
        })

        # delete the selected datasets if the user confirm to delete
        observeEvent(input$confirm_delete_row, {
            if(input$confirm_delete_row){
                # update the Dataset and Dataset_inital
                tmp <- Dataset()
                selected_row <- input$DataBaseTable_rows_selected
                datasets_to_delete <- Filtered_dataset()[selected_row, "Dataset"]
                filepaths_to_delete <- Filtered_dataset()[selected_row, "Path"]
                tmp <- tmp[!tmp$Dataset %in% datasets_to_delete,]
                Dataset(tmp)
                Dataset_initial(tmp)

                # update the filtered dataset
                write.table(Dataset(), 'data/Database.tsv', row.names=F, sep='\t', quote=F)

                # delete the file(s) in the server
                for (filepath in filepaths_to_delete){
                    cat('Deleting file: ', filepath, '\n')
                    if(file.exists(filepath)){
                        file.remove(filepath)
                    }
                }
                show_alert(title='Success!', text='The selected dataset(s) are deleted.', type='success')
                status('Deleted!')
            }
        })

    ## 
}
