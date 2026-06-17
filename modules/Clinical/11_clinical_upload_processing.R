# =============================================================================
# Clinical - Dataset Upload: Processing
# File: modules/Clinical/11_clinical_upload_processing.R
# Purpose: Handles data parsing, transformation, and saving of uploaded cohort
#          files. Writes valid uploads to the data directory and updates the
#          database TSV so the new cohort appears in DataSelection.
# Edit this file when: changing how uploaded files are saved, the directory
#                       structure, or the database TSV schema.
# =============================================================================

upload_processing_server <- function(input, output, session,
                                     Clinical_dataset,
                                     Clinical_dataset_original,
                                     new_cohort_status,
                                     gx_table,
                                     sur_table,
                                     meta_table,
                                     mut_table,
                                     gx_file_path,
                                     sur_file_path,
                                     meta_file_path,
                                     mut_file_path) {
    ## Uplaod
        # check and confirm
            observeEvent(input$new_cohort_upload_data,{
                # check if the mandatory information is provided
                    # gene expression file
                        if(length(gx_table()) == 0 || is.null(gx_table())){
                            show_alert(title='Error', text="The gene expression file is mandatory. Please upload a gene expression file to add a new cohort.", type='error')
                            new_cohort_status("Error: The gene expression file is mandatory. Please upload a gene expression file to add a new cohort.")
                            return()
                        }
                    #

                    # cohort name is only spaces or empty
                        if(trimws(input$new_cohort_upload_dataset_name) == ""){
                            show_alert(title='Error', text="The Cohort name is mandatory. Please provide a unique Cohort name to add a new cohort.", type='error')
                            new_cohort_status("Error: The Cohort name is mandatory. Please provide a unique Cohort name to add a new cohort.")
                            return()
                        }
                    #

                    # cohort name already exists
                        if(input$new_cohort_upload_dataset_name %in% Clinical_dataset()$Database.Name){
                            show_alert(title='Error', text="The Cohort name already exists. Please provide a unique Cohort name to add a new cohort.", type='error')
                            new_cohort_status("Error: The Cohort name already exists. Please provide a unique Cohort name to add a new cohort.")
                            return()
                        }
                    #

                    # If user did not upload either or all of survival, metadata, and mutation data, show warning message
                        if(length(sur_table()) == 0 || is.null(sur_table()) || length(meta_table()) == 0 || is.null(meta_table()) || length(mut_table()) == 0 || is.null(mut_table())){
                            show_alert(title='Warning', text="You did not upload either or all of the survival data, metadata, and mutation data. You can still add the cohort, but you cannot use some of the analysis functions.", type='warning')
                            new_cohort_status("Warning: You did not upload either or all of the survival data, metadata, and mutation data. \nYou can still add the cohort, but you cannot use some of the analysis functions.")
                        }
                    #

                    # show confirmation
                        confirmSweetAlert(
                            session = session,
                            inputId = session$ns("new_cohort_confirm_upload_data"),
                            title = "Are you sure you want to upload the data?",
                            text = "This action cannot be undone.",
                            btn_labels = c("Cancel", "Upload"), # left=False, right=true, so the order of the buttons is Cancel, Upload
                            btn_colors = c("#5b5d6e", "#0ba446")
                        )
                    #
            })
        #

        # once you confirm
            observeEvent(input$new_cohort_confirm_upload_data, {
                time_stamp <- as.character(Sys.time())
                Year <- format(Sys.time(), "%Y")
                date <- format(Sys.time(), "%m.%d")
                dir.create(file.path('00_Clinical_dataset', Year, date), recursive=T, showWarnings = F)


                if(length(gx_file_path) != 0 && !is.null(gx_file_path())){
                    save_gx_path <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_dataset_name, '-GeneExpression.tsv'))
                    write.table(gx_table(), save_gx_path, row.names=F, sep='\t', quote=F)
                }else{
                    save_gx_path <- NULL
                }

                if(length(sur_file_path) != 0 && !is.null(sur_file_path())){
                    save_sur_path <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_dataset_name, '-Survival.tsv'))
                    file.copy(sur_file_path(), save_sur_path, overwrite = TRUE)
                }else{
                    save_sur_path <- NULL
                }

                if(length(meta_file_path) != 0 && !is.null(meta_file_path())){
                    save_meta_path <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_dataset_name, '-Metadata.tsv'))
                    file.copy(meta_file_path(), save_meta_path, overwrite = TRUE)
                }else{
                    save_meta_path <- NULL
                }

                if(length(mut_file_path) != 0 && !is.null(mut_file_path())){
                    save_mut_path <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_dataset_name, '-Mutation.tsv'))
                    file.copy(mut_file_path(), save_mut_path, overwrite = TRUE)
                }else{
                    save_mut_path <- NULL
                }

                # description. replace '\n' with a space
                Description <- unlist(strsplit(input$new_cohort_upload_description, split = "\n"))
                Description <- paste(Description, collapse = " ")


                tmp <- Clinical_dataset()
                tmp <- add_row(tmp,
                    Database.Name=input$new_cohort_upload_dataset_name ,
                    Description=Description,
                    Expression_path= save_gx_path,
                    Survival_path= save_sur_path,
                    Meta_path= save_meta_path,
                    added.when= time_stamp,
                    Mutation_path= save_mut_path)
                tmp <- tmp[order(tmp$added.when, decreasing =T),]
                Clinical_dataset(tmp)
                Clinical_dataset_original(tmp)
                write.table(Clinical_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
                show_alert(title='Success!', text='The cohort was successfully uploaded.', type='success')

                # show a status
                    message <- paste0("You successfully uploaded the new cohort: ", input$new_cohort_upload_dataset_name)
                    new_cohort_status(message)
                #


            })
    ##
}
