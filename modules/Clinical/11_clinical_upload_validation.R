# =============================================================================
# Clinical - Dataset Upload: Validation
# File: modules/Clinical/11_clinical_upload_validation.R
# Purpose: Handles file format checking, header validation, and error messages
#          for all four upload file types (expression, survival, metadata, mutation).
# Edit this file when: changing upload validation logic or expected file format
#                       for clinical data.
# =============================================================================

upload_validation_server <- function(input, output, session) {
    ## Show already uploaded cohorts ----
        # database load
            Clinical_dataset <- reactiveVal({data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE))})
            Clinical_dataset_original <- reactiveVal({data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE))})
        #

        # reload database
            observeEvent(input$Clinical_data_reload, {
                Clinical_dataset(data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE)))
            })
        #

        # status
            Cohort_DataBase_status <- reactiveVal(NULL)
            output$Cohort_DataBase_status <- renderText({ Cohort_DataBase_status() })
        #

        # Show as a table
            output$Cohort_DataBaseTable <- DT::renderDataTable({
                data_table_tmp <- Clinical_dataset()[order(Clinical_dataset()$added.when, decreasing =T),]
                data_table_tmp <- data_table_tmp[,c( "Database.Name", "Description")]
                datatable(data_table_tmp,
                    selection='none', extensions=c('Select'), rownames=FALSE,
                    options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0),
                    editable= list(target = 'cell', disable = list(columns = c(0))) # you cannot edit the dataset name (the first column)
                    )
                },server = FALSE)
        #

        # Edit the dataset table and save the changes to the original cohort dataset
            edit_flag <- reactiveVal(FALSE)
            observeEvent(input$Cohort_DataBaseTable_cell_edit,{
                # detect the edited cell
                info <- input$Cohort_DataBaseTable_cell_edit
                edit_flag(TRUE)
                Cohort_DataBase_status(paste0("You edited a cell.", "\nOld value: ", Clinical_dataset()[info$row, info$col+1], "\nNew value: ", info$value, "\nPress 'Save changes' to save the edit."))

                # update 'Clinical_dataset'
                tmp <- Clinical_dataset()
                tmp[info$row, info$col+1] <- info$value
                Clinical_dataset(tmp)
            })
        #

        ## Save the edited dataset to the original dataset and write to the tsv file
            # confirmation button
            observeEvent(input$Cohort_DataBase_save_dt,{
                if(!edit_flag()){
                    show_alert(title='No changes detected', text='You have not made any changes to save.', type='info')
                    return()
                }
                confirmSweetAlert(
                    session = session,
                    inputId = session$ns("Cohort_DataBase_confirm_save_dt"),
                    title = "Are you sure you want to save the changes?",
                    text = "This action cannot be undone.",
                    btn_labels = c("Cancel", "Save"), # left=False, right=true, so the order of the buttons is Cancel, Save
                    btn_colors = c("#5b5d6e", "#bc2929")
                )
            })

            # save the changes if the user confirm to save
            observeEvent(input$Cohort_DataBase_confirm_save_dt, {
                if(input$Cohort_DataBase_confirm_save_dt){
                    Clinical_dataset_original(Clinical_dataset())
                    write.table(Clinical_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
                    show_alert(title='Success!', text='The changes are saved.', type='success')
                    Cohort_DataBase_status('All changes are saved.')
                    edit_flag(FALSE)
                }
            })
        #

        # delete
            # Confirm the deletion. Show which dataset will be deleted and ask the user to confirm the deletion.
            observeEvent(input$Cohort_DataBase_delete_row, {
                selected_row <- input$Cohort_DataBaseTable_rows_selected
                if(length(selected_row)==0){
                    show_alert(title='Error.',text='No row selected!', type='error')
                    return()
                }
                datasets_to_delete <- Clinical_dataset()[selected_row, "Database.Name"]
                confirmSweetAlert(
                    session = session,
                    inputId = session$ns("Cohort_confirm_delete_row"),
                    title = "Are you sure you want to delete the selected dataset(s)?",
                    text = paste0("The following dataset(s) will be deleted:\n", paste('"', datasets_to_delete, '"', collapse = "\n"), "\nThis action cannot be undone."),
                    btn_labels = c("Cancel", "Delete"), # left=False, right=true, so the order of the buttons is Cancel, Delete
                    btn_colors = c("#5b5d6e", "#1C07A6")
                )
            })

            # delete the selected datasets if the user confirm to delete
            observeEvent(input$Cohort_confirm_delete_row, {
                if(input$Cohort_confirm_delete_row){
                    # update the Dataset and Dataset_inital
                    tmp <- Clinical_dataset()
                    selected_row <- input$Cohort_DataBaseTable_rows_selected
                    datasets_to_delete <- Clinical_dataset()[selected_row, "Database.Name"]
                    filepaths_to_delete <- c(Clinical_dataset()[selected_row, "Expression_path"],
                                             Clinical_dataset()[selected_row, "Survival_path"],
                                             Clinical_dataset()[selected_row, "Meta_path"],
                                             Clinical_dataset()[selected_row, "Mutation_path"])
                    tmp <- tmp[!tmp$Database.Name %in% datasets_to_delete,]
                    Clinical_dataset(tmp)
                    Clinical_dataset_original(tmp)

                    # update the filtered dataset
                    write.table(Clinical_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)

                    # delete the file(s) in the server
                    for (filepath in filepaths_to_delete){
                        cat('Deleting file: ', filepath, '\n')
                        if(file.exists(filepath)){
                            file.remove(filepath)
                        }
                    }
                    show_alert(title='Success!', text='The selected dataset(s) are deleted.', type='success')
                    Cohort_DataBase_status('Deleted')
                }
            })
        #
    ##

    ## Upload
        # status
            new_cohort_status <- reactiveVal("Please upload files and fill in the information to add a new cohort.")
            output$new_cohort_status <- renderText({ new_cohort_status() })
        #

        # upload UI. All of them can accpet only tsv,txt (tab delimited) files.
            output$new_cohort_upload_GE <- renderUI({ fileInput(session$ns("new_cohort_upload_GE"), "Upload a Gene expression file* (tab delimited, mandatory)", accept = c(".tsv", ".txt")) })
            output$new_cohort_upload_sur <- renderUI({ fileInput(session$ns("new_cohort_upload_sur"), "Upload a survival data file (tab delimited)", accept = c(".tsv", ".txt")) })
            output$new_cohort_upload_meta <- renderUI({ fileInput(session$ns("new_cohort_upload_meta"), "Upload a metadata file (tab delimited)", accept = c(".tsv", ".txt")) })
            output$new_cohort_upload_mut <- renderUI({ fileInput(session$ns("new_cohort_upload_mut"), "Upload a mutation data file (tab delimited)", accept = c(".tsv", ".txt")) })
        #

        # uploaded data
            gx_table <- reactiveVal(NULL)
            sur_table <- reactiveVal(NULL)
            meta_table <- reactiveVal(NULL)
            mut_table <- reactiveVal(NULL)
            gx_file_path <- reactiveVal(NULL)
            sur_file_path <- reactiveVal(NULL)
            meta_file_path <- reactiveVal(NULL)
            mut_file_path <- reactiveVal(NULL)
        #

        # reset
            observeEvent(input$new_cohort_upload_reset, {
                updateTextInput(session, "new_cohort_upload_dataset_name", value = "")
                updateTextAreaInput(session, "new_cohort_upload_description", value = "")
                # reset file input by removing the existing file input and creating a new one
                output$new_cohort_upload_GE <- renderUI({ fileInput(session$ns("new_cohort_upload_GE"), "Upload a Gene expression file* (tab delimited, mandatory)", accept = c(".tsv", ".txt")) })
                output$new_cohort_upload_sur <- renderUI({ fileInput(session$ns("new_cohort_upload_sur"), "Upload a survival data file (tab delimited)", accept = c(".tsv", ".txt")) })
                output$new_cohort_upload_meta <- renderUI({ fileInput(session$ns("new_cohort_upload_meta"), "Upload a metadata file (tab delimited)", accept = c(".tsv", ".txt")) })
                output$new_cohort_upload_mut <- renderUI({ fileInput(session$ns("new_cohort_upload_mut"), "Upload a mutation data file (tab delimited)", accept = c(".tsv", ".txt")) })
                # reset the reactive values
                gx_table(NULL)
                sur_table(NULL)
                meta_table(NULL)
                mut_table(NULL)
                gx_file_path(NULL)
                sur_file_path(NULL)
                meta_file_path(NULL)
                mut_file_path(NULL)
                new_cohort_status("Please upload files and fill in the information to add a new cohort.")
            })
        #

        # load data
            # expression
                observeEvent(input$new_cohort_upload_GE, {
                    gx_file <- input$new_cohort_upload_GE

                    # check the extension
                        if(tools::file_ext(gx_file$name) != "tsv" & tools::file_ext(gx_file$name) != "txt"){
                            show_alert(title='Error', text="Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.", type='error')
                            new_cohort_status("Error: Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.")
                            gx_table(NULL)
                            gx_file_path(NULL)
                            return()
                        }
                    #
                    df_tmp <- read.table(gx_file$datapath, sep='\t', header=T,check.names = FALSE)



                    # colnames should contain 'id'
                        if(!'id' %in% colnames(df_tmp)){
                            show_alert(title='Error', text="The gene expression file must contain a column named 'id' for gene names.", type='error')
                            new_cohort_status("Error: The gene expression file must contain a column named 'id' for gene names.")
                            gx_table(NULL)
                            gx_file_path(NULL)
                            return()
                        }
                    #

                    # if duplicated genes were found, take the average of the duplicated genes and show a warning message
                        duplicate_flag <- FALSE
                        if(any(duplicated(df_tmp$id))){
                            show_alert(title='Warning', text="Duplicated gene names were found in the gene expression file. The average expression values will be taken for the duplicated genes.", type='warning')
                            new_cohort_status("Warning: Duplicated gene names were found in the gene expression file. The average expression values will be taken for the duplicated genes.")
                            df_tmp <- df_tmp %>% group_by(id) %>% summarise_all(mean)
                            duplicate_flag <- TRUE
                        }
                    #

                    if(duplicate_flag){
                        message <- "You uploaded a gene expression file successfully. Please fill in the other information and click the 'Add a new cohort' button. \nWarning: Duplicated gene names were found in the gene expression file. The average expression values will be taken for the duplicated genes."
                    }else{
                        message <- "You uploaded a gene expression file successfully. Please fill in the other information and click the 'Add a new cohort' button."
                    }
                    new_cohort_status(message)
                    gx_table(df_tmp)
                    gx_file_path(gx_file$datapath)

                })
            #

            # survival
                observeEvent(input$new_cohort_upload_sur, {
                    sur_file <- input$new_cohort_upload_sur
                    # check the extension
                        if(tools::file_ext(sur_file$name) != "tsv" & tools::file_ext(sur_file$name) != "txt"){
                            show_alert(title='Error', text="Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.", type='error')
                            new_cohort_status("Error: Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.")
                            sur_table(NULL)
                            sur_file_path(NULL)
                            return()
                        }
                    #

                    df_tmp <- read.table(sur_file$datapath, sep='\t', header=T,check.names = FALSE)

                    # colnames should contain 'sample'
                        if(!'sample' %in% colnames(df_tmp)){
                            show_alert(title='Error', text="The survival data file must contain a column named 'sample' for sample names.", type='error')
                            new_cohort_status("Error: The survival data file must contain a column named 'sample' for sample names.")
                            sur_table(NULL)
                            sur_file_path(NULL)
                            return()
                        }
                    #

                    # suvival data liks OS or PFS should be a pair. ex. The cencor data is 'OS' and the time is 'OS.time'. similary, 'PFS' and 'PFS.time' for any event.
                        event_cols <- colnames(df_tmp)[!colnames(df_tmp) %in% c("sample")]
                        event_names <- event_cols[grepl("\\.time", event_cols, ignore.case = TRUE)]
                        if(length(event_names) == 0){
                            show_alert(title='Error', text="No survival time column found. The survival data file must contain at least one pair of survival event and time columns.", type='error')
                            new_cohort_status("Error: No survival time column found. The survival data file must contain at least one pair of survival event and time columns. \nThe time column should have the same name as the event column with '.time' suffix. \nFor example, if the event column is 'OS', the time column should be 'OS.time'.")
                            sur_table(NULL)
                            sur_file_path(NULL)
                            return()
                        }
                    #

                    sur_table(df_tmp)
                    sur_file_path(sur_file$datapath)
                    new_cohort_status('You uploaded a survival data file successfully. Please fill in the other information and click the "Add a new cohort" button.')
                })
            #

            # meta data
                observeEvent(input$new_cohort_upload_meta, {
                    meta_data <- input$new_cohort_upload_meta
                    # check the extension
                        if(tools::file_ext(meta_data$name) != "tsv" & tools::file_ext(meta_data$name) != "txt"){
                            show_alert(title='Error', text="Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.", type='error')
                            new_cohort_status("Error: Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.")
                            meta_table(NULL)
                            meta_file_path(NULL)
                            return()
                        }
                    #
                    df_tmp <- read.delim(meta_data$datapath, header=T,check.names = FALSE)

                    # colnames should contain 'sample'
                        if(!'sample' %in% colnames(df_tmp)){
                            show_alert(title='Error', text="The metadata file must contain a column named 'sample' for sample names.", type='error')
                            new_cohort_status("Error: The metadata file must contain a column named 'sample' for sample names.")
                            meta_table(NULL)
                            meta_file_path(NULL)
                            return()
                        }
                    #
                    meta_table(df_tmp)
                    meta_file_path(meta_data$datapath)
                    new_cohort_status('You uploaded a metadata file successfully. Please fill in the other information and click the "Add a new cohort" button.')
                })
            #

            # mutation data
                observeEvent(input$new_cohort_upload_mut, {
                    mut_data <- input$new_cohort_upload_mut
                    # check the extension
                        if(tools::file_ext(mut_data$name) != "tsv" & tools::file_ext(mut_data$name) != "txt"){
                            show_alert(title='Error', text="Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.", type='error')
                            new_cohort_status("Error: Invalid file type. Please upload a tab delimited file with .tsv or .txt extension.")
                            mut_table(NULL)
                            mut_file_path(NULL)
                            return()
                        }
                    #
                    df_tmp <- read.delim(mut_data$datapath, header=T,check.names = FALSE)

                    # colnames should contain 'id'
                        if(!'id' %in% colnames(df_tmp)){
                            show_alert(title='Error', text="The mutation data file must contain a column named 'id' for gene names.", type='error')
                            new_cohort_status("Error: The mutation data file must contain a column named 'id' for gene names.")
                            mut_table(NULL)
                            mut_file_path(NULL)
                            return()
                        }
                    #

                    # colnames should contain 'sample'
                        if(!'sample' %in% colnames(df_tmp)){
                            show_alert(title='Error', text="The mutation data file must contain a column named 'sample' for sample names.", type='error')
                            new_cohort_status("Error: The mutation data file must contain a column named 'sample' for sample names.")
                            mut_table(NULL)
                            mut_file_path(NULL)
                            return()
                        }
                    #
                    mut_table(df_tmp)
                    mut_file_path(mut_data$datapath)
                    new_cohort_status('You uploaded a mutation data file successfully. Please fill in the other information and click the "Add a new cohort" button.')
                })
            #

        # preview
            # expression
                new_cohort_upload_GE_preview_status <- reactiveVal(NULL)
                output$new_cohort_upload_GE_preview_status <- renderText({ new_cohort_upload_GE_preview_status() })
                output$new_cohort_upload_GE_preview <- renderDataTable({
                    if(is.null(gx_table())){
                        new_cohort_upload_GE_preview_status("No gene expression data uploaded yet. A preview will be shown here once you upload a gene expression file.")
                        return(NULL)
                    }else{
                        new_cohort_upload_GE_preview_status("The below are the first 10 lines.")
                        datatable( head(gx_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE ))
                    }
                })
            #

            # survival
                new_cohort_upload_sur_preview_status <- reactiveVal(NULL)
                output$new_cohort_upload_sur_preview_status <- renderText({ new_cohort_upload_sur_preview_status() })
                output$new_cohort_upload_sur_preview <- renderDataTable({
                    if(is.null(sur_table())){
                        new_cohort_upload_sur_preview_status("No survival data uploaded yet. A preview will be shown here once you upload a survival data file.")
                        return(NULL)
                    }else{
                        new_cohort_upload_sur_preview_status("The below are the first 10 lines.")
                        datatable( head(sur_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE ))
                    }
                })
            #

            # metadata
                new_cohort_upload_meta_preview_status <- reactiveVal(NULL)
                output$new_cohort_upload_meta_preview_status <- renderText({ new_cohort_upload_meta_preview_status() })
                output$new_cohort_upload_meta_preview <- renderDataTable({
                    if(is.null(meta_table())){
                        new_cohort_upload_meta_preview_status("No metadata uploaded yet. A preview will be shown here once you upload a metadata file.")
                        return(NULL)
                    }else{
                        new_cohort_upload_meta_preview_status("The below are the first 10 lines.")
                        datatable( head(meta_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE ))
                    }
                })
            #

            # mutation data
                new_cohort_upload_mut_preview_status <- reactiveVal(NULL)
                output$new_cohort_upload_mut_preview_status <- renderText({ new_cohort_upload_mut_preview_status() })
                output$new_cohort_upload_mut_preview <- renderDataTable({
                    if(is.null(mut_table())){
                        new_cohort_upload_mut_preview_status("No mutation data uploaded yet. A preview will be shown here once you upload a mutation data file.")
                        return(NULL)
                    }else{
                        new_cohort_upload_mut_preview_status("The below are the first 10 lines.")
                        datatable( head(mut_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE ))
                    }
                })
            #
        #

    ##

    return(list(
        Clinical_dataset         = Clinical_dataset,
        Clinical_dataset_original = Clinical_dataset_original,
        new_cohort_status        = new_cohort_status,
        gx_table                 = gx_table,
        sur_table                = sur_table,
        meta_table               = meta_table,
        mut_table                = mut_table,
        gx_file_path             = gx_file_path,
        sur_file_path            = sur_file_path,
        meta_file_path           = meta_file_path,
        mut_file_path            = mut_file_path
    ))
}
