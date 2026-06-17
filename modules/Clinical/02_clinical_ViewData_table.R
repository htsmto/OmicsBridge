# =============================================================================
# Clinical - View Data: Table Rendering & Metadata Editing
# File: modules/Clinical/02_clinical_ViewData_table.R
# Purpose: Renders DT preview tables for expression, survival, metadata, and
#          mutation data. Also handles add/delete metadata column UI and logic.
# Edit this file when: changing table display options, adding new table outputs,
#                       or modifying the metadata add/delete workflow.
# =============================================================================

viewdata_table_server <- function(input, output, session, gene_expression_data, survival_data, meta_data, mutation_data, meta_path) {
    ## Expression table
        output$Clinical_View_Geneexpression <- DT::renderDataTable({
            if(is.null(gene_expression_data())){
                return(NULL)
            }else{
                if(input$Clinical_View_EX_show_number == 'A'){
                    return(DT::datatable(gene_expression_data()[1:1000,], options = list(scrollX = TRUE, pageLength = 10, server=TRUE)))
                }else{
                    return(DT::datatable(gene_expression_data(), options = list(scrollX = TRUE, pageLength = 10, server=TRUE)))
                }
            }
        })
    ##

    ## Survival table
        output$Clinical_View_Survival <- DT::renderDataTable({
            if(is.null(survival_data())){
                return(NULL)
            }else{
                return(DT::datatable(survival_data(), options = list(scrollX = TRUE, pageLength = 10, server=TRUE)))
            }
        })
    ##

    ## Meta data table
        output$Clinical_View_MetaData <- DT::renderDataTable({
            if(is.null(meta_data())){
                return(NULL)
            }else{
                return(DT::datatable(meta_data(), options = list(scrollX = TRUE, pageLength = 10, server=TRUE)))
            }
        })
    ##

    ## Add a new metadata column
        # UI
            output$Clinical_view_edit_metadata_ui <- renderUI({
                if(input$Clinical_view_edit_metadata == TRUE){
                    fluidRow(
                        column(2, textInput(session$ns('Clinical_view_new_metadata_column'), 'New metadata column name')),
                        column(4, textAreaInput(session$ns('Clinical_view_new_metadata_column_values'), 'New metadata column values', placeholder = 'Enter values as the fllowing: \nsample1,value1\nsample2,value2\n(sample id and value separated by a comma)')),
                        column(6,
                            fluidRow(
                                column(12, h3('\n')),
                                column(10, verbatimTextOutput(session$ns('Clinical_view_new_metadata_column_status'))),
                                column(12, actionButton(session$ns('Clinical_view_add_metadata'), 'Add a new column', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                column(12, h3(''))
                            )
                        )
                    )
                }else{
                    return(NULL)
                }
            })

        #

        # status
            Clinical_view_new_metadata_column_status <- reactiveVal('Please enter the new metadata column name and values, then click the button to add the new column.')
            output$Clinical_view_new_metadata_column_status <- renderText({ Clinical_view_new_metadata_column_status() })

        #

        # add the new metadata column to the meta data table
            Clinical_view_new_column <- reactiveVal(NULL)
            Clinical_view_new_column_values <- reactiveVal(NULL)
            observe({
                Clinical_view_new_column(input$Clinical_view_new_metadata_column)
                Clinical_view_new_column_values(input$Clinical_view_new_metadata_column_values)
            })

            # start
            observeEvent(input$Clinical_view_add_metadata, {
                # when there is no meta data loaded, show an error message
                if(is.null(meta_data())){
                    show_alert(title='Error.', text='No meta data loaded. Please make sure the meta data is loaded before adding a new metadata column.', type='error')
                    Clinical_view_new_metadata_column_status('No meta data loaded.')
                    return()
                }

                # validate the input
                if(length(Clinical_view_new_column()) == 0 || is.null(Clinical_view_new_column()) || nchar(Clinical_view_new_column()) == 0){
                    show_alert(title='Error.', text='Please enter the new metadata column name.', type='error')
                    Clinical_view_new_metadata_column_status('Please enter the new metadata column name.')
                    return()
                }

                # validate the input values
                if(length(Clinical_view_new_column_values()) == 0 || is.null(Clinical_view_new_column_values()) || nchar(paste(Clinical_view_new_column_values(), collapse = "\n")) == 0){
                    show_alert(title='Error.', text='Please enter the new metadata column values.', type='error')
                    Clinical_view_new_metadata_column_status('Please enter the new metadata column values.')
                    return()
                }

                # check if the format of the input values is correct
                lines <- paste(Clinical_view_new_column_values(), collapse = "\n")
                if(!all(grepl(',', lines))){
                    show_alert(title='Error.', text='Each line must contain exactly one comma separating sample ID and value.', type='error')
                    Clinical_view_new_metadata_column_status(lines)
                    return()
                }

                # check if there are duplicates in the sample IDs
                df_column <- read.csv(text = lines, header = FALSE, stringsAsFactors = FALSE)
                sample_ids <- df_column[[1]]
                new_values <- df_column[[2]]
                if(any(duplicated(sample_ids))){
                    show_alert(title='Error.', text='Duplicate sample IDs found.', type='error')
                    Clinical_view_new_metadata_column_status('Duplicate sample IDs found.')
                    return()
                }

                # check the ids not in the metadata
                sample_ids_intersect <- intersect(sample_ids, meta_data()$sample)
                sample_ids_diff <- setdiff(sample_ids, meta_data()$sample)
                if(length(sample_ids_intersect)==0){
                    show_alert(title='Error.', text='None of the input samples are found in the metadata', type='error')
                    Clinical_view_new_metadata_column_status('None of the input samples are found in the metadata')
                    return()
                }

                # update the meta table
                if(length(sample_ids_diff) > 0){
                    show_alert(title='Warning.', text=paste0('The following samples are not found in the metadata and will be ignored: ', paste(sample_ids_diff, collapse = ', ')), type='warning')
                    Clinical_view_new_metadata_column_status(paste0('The following samples are not found in the metadata and will be ignored: ', paste(sample_ids_diff, collapse = ', ')))
                }
                Clinical_meta_tmp <- meta_data()
                # new column name
                new_col_name <- Clinical_view_new_column()
                Clinical_meta_tmp[[new_col_name]] <- ""
                common_ids <- sample_ids_intersect
                for (sid in common_ids) {
                    value <- new_values[sample_ids == sid][1]  # 同じIDが複数行あっても最初を使う
                    Clinical_meta_tmp[Clinical_meta_tmp$sample == sid, new_col_name] <- value
                }
                meta_data(Clinical_meta_tmp)
                # re-write the meta data to the original path(meta_path())
                write.table(meta_data(), file = meta_path(), sep='\t', quote=F, row.names=F)
                show_alert(title='Success.', text=paste0('The new metadata column "', new_col_name, '" has been added.'), type='success')
            })
    ##


    ## Delete a metadata column
        # UI
            output$Clinical_view_delete_metadata_ui <- renderUI({
                if(input$Clinical_view_delete_metadata_switch == TRUE){
                    fluidRow(
                        column(4,
                            verbatimTextOutput(session$ns('Clinical_view_delete_metadata_status')),
                            htmlOutput(session$ns('Clinical_view_delete_metadata_select'))
                        ),
                        column(4,
                            h2('\n'),
                            actionButton(session$ns('Clinical_view_delete_metadata_confirm'), 'Delete the column', style="color: #ffffff; background-color: #40454d; border-color: #bd0000")
                        )

                    )
                }else{
                    return(NULL)
                }
            })

        #

        # status
            Clinical_view_delete_metadata_status <- reactiveVal('Please select a metadata column to delete, then click the button to confirm the deletion.')
            output$Clinical_view_delete_metadata_status <- renderText({ Clinical_view_delete_metadata_status() })

        #

        # selection UI
            output$Clinical_view_delete_metadata_select <- renderUI({
                if(input$Clinical_view_delete_metadata_switch == TRUE){
                    if(is.null(meta_data())){
                        selectInput(session$ns('Clinical_view_delete_metadata_select'), 'Select a column to delete', choices = c('--Please select a dataset first--'='None'), selected = NULL)
                    }else{
                        selection <- colnames(meta_data())
                        selection <- selection[selection != "sample"] # delete 'sample' from selection
                        selectInput(session$ns('Clinical_view_delete_metadata_select'), 'Select a column to delete', choices = c('None'='None', selection), selected = NULL)
                    }
                }else{
                    return(NULL)
                }
            })

        #

        # delete
            observeEvent(input$Clinical_view_delete_metadata_confirm, {
                if(length(input$Clinical_view_delete_metadata_select) != 0){
                    if(input$Clinical_view_delete_metadata_select == 'None'){
                        show_alert(title='Error.', text='Please select a column to delete.', type='error')
                        return()
                    }else{
                        # show a confirmation dialog
                        confirmSweetAlert(
                            session = session,
                            inputId = session$ns("confirm_delete_metadata"),
                            title = "Are you sure you want to delete the column?",
                            text = paste0("This action cannot be undone. The column '", input$Clinical_view_delete_metadata_select, "' will be deleted."),
                            btn_labels = c("Cancel", "Delete"), # left=False, right=true, so the order of the buttons is Cancel, Delete
                            btn_colors = c("#5b5d6e", "#d82a2a")
                        )
                    }
                }
            })

            observeEvent(input$confirm_delete_metadata, {
                req(input$confirm_delete_metadata)
                if(input$confirm_delete_metadata == TRUE){
                    Clinical_meta_tmp <- meta_data()
                    Clinical_meta_tmp[[input$Clinical_view_delete_metadata_select]] <- NULL
                    meta_data(Clinical_meta_tmp)
                    # re-write the meta data to the original path(meta_path())
                    write.table(meta_data(), file = meta_path(), sep='\t', quote=F, row.names=F)
                    show_alert(title='Success.', text=paste0("The column '", input$Clinical_view_delete_metadata_select, "' has been deleted."), type='success')
                }
            })

        #

    ##

    ## Mutation table
        output$Clinical_View_Mutation <- DT::renderDataTable({
            if(is.null(mutation_data())){
                return(NULL)
            }else{
                return(DT::datatable(mutation_data(), options = list(scrollX = TRUE, pageLength = 10, server=TRUE)))
            }
        })
    ##
}
