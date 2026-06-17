# =============================================================================
# OriginalDataset (Custom Gene Sets) - Table View Server
# File: modules/OriginalDataset/01_OriginalDataset_TableView_server.R
# Purpose: Reads Genesets_list.tsv and displays the custom gene set library
#          as an interactive table. Users can browse gene set names and members.
# Edit this file when: changing the table display, adding a search/preview
#                       panel, or modifying how the TSV is parsed.
# =============================================================================

original_geneset_tableview_server <- function(input, output, session) {
    ## initial settings
        ## Status
            Original_geneset_status <- reactiveVal(NULL)
            edit_flag <- reactiveVal(FALSE)

        ## show the satsus text
            output$Original_geneset_status <- renderText(Original_geneset_status())

        ## load the full database
            Original_geneset_list <- reactiveVal(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))
            Original_geneset_list_initial <- reactiveVal(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))

        ## Reload the Dataset
            observeEvent(input$Original_geneset_Reload, {
                Original_geneset_list(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))
                Original_geneset_list_initial(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))
            })

    ## Show the data list
        # show a data table
            output$Original_geneset_DataBaseTable <-  DT::renderDataTable({
                # copy the data to a temporary variable for display
                data_table_tmp <- Original_geneset_list()[order(Original_geneset_list()$Added.When, decreasing =T),]
                data_table_tmp <- data_table_tmp[,c('Geneset.name','Description','Cell.type','Data.source', 'Genes')]

                # show the data table with specific options
                datatable(data_table_tmp, 
                    selection='none', extensions=c('Select'), rownames=F,
                    options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0), 
                    editable= list(target = 'cell', disable = list(columns = c(0))) # you cannot edit the dataset name (the first column)
                ) 
            },server = FALSE)    

        # edit
            observeEvent(input$Original_geneset_DataBaseTable_cell_edit,{
                # detect the edited cell 
                info <- input$Original_geneset_DataBaseTable_cell_edit
                edit_flag(TRUE)
                Original_geneset_status(paste0("You edited a cell.", "\nOld value: ", Original_geneset_list()[info$row, info$col+1], "\nNew value: ", info$value, "\nPress 'Save changes' to save the edit."))

                # update 'Original_geneset_list' by the edited value
                tmp <- Original_geneset_list()
                tmp[info$row, info$col+1] <- info$value
                Original_geneset_list(tmp)
            })

    ##

    ## Save the edited dataset to the original dataset and write to the tsv file
        # confirmation button
        observeEvent(input$Original_geneset_save_dt,{
            if(!edit_flag()){
                show_alert(title='No changes detected', text='You have not made any changes to save.', type='info')
                return()
            }
            confirmSweetAlert(
                session = session,
                inputId = session$ns("Original_geneset_confirm_save_dt"),
                title = "Are you sure you want to save the changes?",
                text = "This action cannot be undone.",
                btn_labels = c("Cancel", "Save"), # left=False, right=true, so the order of the buttons is Cancel, Save
                btn_colors = c("#5b5d6e", "#bc2929")
            ) 
        })

        # save the changes if the user confirm to save
        observeEvent(input$Original_geneset_confirm_save_dt, {
            if(input$Original_geneset_confirm_save_dt){
                Original_geneset_list_initial(Original_geneset_list())
                write.table(Original_geneset_list(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)
                show_alert(title='Success!', text='The changes are saved.', type='success')
                Original_geneset_status('All changes are saved.')
                edit_flag(FALSE)
            }
        })

    ##

    ## Delete selected datasets
        # Confirm the deletion. Show which dataset will be deleted and ask the user to confirm the deletion.
        observeEvent(input$Original_geneset_delete_row, {
            selected_row <- input$Original_geneset_DataBaseTable_rows_selected
            if(length(selected_row)==0){
                show_alert(title='Error.',text='No row selected!', type='error')
                return()
            }
            datasets_to_delete <- Original_geneset_list()[selected_row, "Geneset.name"]
            confirmSweetAlert(
                session = session,
                inputId = session$ns("Original_geneset_confirm_delete_row"),
                title = "Are you sure you want to delete the selected geneset(s)?",
                text = paste0("The following geneset(s) will be deleted:\n", paste('"', datasets_to_delete, '"', collapse = "\n"), "\nThis action cannot be undone."),
                btn_labels = c("Cancel", "Delete"), # left=False, right=true, so the order of the buttons is Cancel, Delete
                btn_colors = c("#5b5d6e", "#1C07A6")
            )
        })

        # delete the selected genesets if the user confirm to delete
        observeEvent(input$Original_geneset_confirm_delete_row, {
            if(input$Original_geneset_confirm_delete_row){
                # update the Original_geneset and Original_geneset_initial by removing the selected geneset(s)
                tmp <- Original_geneset_list()
                selected_row <- input$Original_geneset_DataBaseTable_rows_selected
                datasets_to_delete <- Original_geneset_list()[selected_row, "Geneset.name"]
                tmp <- tmp[!tmp$Geneset.name %in% datasets_to_delete,]
                Original_geneset_list(tmp)
                Original_geneset_list_initial(tmp)

                # update the filtered dataset
                write.table(Original_geneset_list(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)

                # status
                show_alert(title='Success!', text='The selected dataset(s) are deleted.', type='success')
                Original_geneset_status('Deleted!')
            }
        })

    ##

}