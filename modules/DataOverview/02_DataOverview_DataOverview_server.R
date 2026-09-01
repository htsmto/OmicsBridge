# =============================================================================
# DataOverview - Data Loading & Overview Server
# File: modules/DataOverview/02_DataOverview_DataOverview_server.R
# Purpose: Loads the expression data file for the selected dataset and returns
#          it as a reactive data frame (df_ex) used by all analysis sub-servers.
#          Also renders the overview tab (sample count, gene count, summary stats).
# Edit this file when: changing how expression data is read/normalised,
#                       or modifying the overview statistics table.
# =============================================================================

dataoverview_dataoverview_Server <- function(input, output, session) {
    ## variable, initial settings
        Dataset <- reactiveVal(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
        df_raw <- reactiveVal(NULL)        # untouched, as-loaded table (before any normalisation)
        df_overview <- reactiveVal(NULL)   # currently displayed / used-downstream table (raw, or user-normalised)
        status <- reactiveVal(NULL)
        normalisation_status <- reactiveVal(NULL)

        # gene length lookup for TPM/FPKM (NULL if the file is missing/unreadable; CPM doesn't need it)
        gene_lengths <- reactive({ load_gene_lengths() })

        # reload database
            observeEvent(input$reload_database, {
                Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
            })
        #   

    ## show the status
        output$Count_data_DataTable_status <- renderText({status()})
        output$DataTable_status <- renderText({status()})


    ## data loading
        observe({
            selected_dataset <- input$Dataset_select
            
            if(length(selected_dataset) != 0 && selected_dataset != 'None'){
                # get the path of the selected dataset and check if the file exists
                dataset_path <- Dataset()[Dataset()$Dataset == input$Dataset_select,]$Path
                if(file.exists(dataset_path)){
                    df_tmp <- read.table(dataset_path, header=T, check.names = FALSE, sep='\t')
                    numeric_cols <- names(df_tmp)[!(names(df_tmp) %in% 'id')]
                    df_tmp[numeric_cols] <- lapply(df_tmp[numeric_cols], function(col){
                        converted <- suppressWarnings(as.numeric(col))
                        # as.numeric() turning every value to NA means the column was never numeric to begin with; keep it as-is
                        if(all(is.na(converted)) && !all(is.na(col))){
                            col
                        } else {
                            converted
                        }
                    })
                    df_tmp <- replace_infinite_values_df(df_tmp)
                    status(NULL)
                    df_raw(df_tmp)
                    df_overview(df_tmp)
                    normalisation_status(NULL)
                } else {
                    show_alert(paste0("The file for the selected dataset does not exist. \nPlease re-upload the dataset."), type = "error")
                    status("The file for the selected dataset does not exist. \nPlease re-upload the dataset.")
                    df_raw(NULL)
                    df_overview(NULL)
                    normalisation_status(NULL)
                    return()
                }
            }else{
                df_raw(NULL)
                df_overview(NULL)
                status(NULL)
                normalisation_status(NULL)
                return()
            }
        })

    ## normalisation (Data.Class == 'A' only; control not shown for class B)
        observeEvent(input$apply_normalisation, {
            method <- input$normalisation_method
            method_label <- c(none = "None", cpm = "CPM", tpm = "TPM", fpkm = "FPKM")[method]

            result <- normalise_counts(df_raw(), method, gene_lengths())

            if(!is.null(result$error)){
                show_alert(result$error, type = "error")
                normalisation_status(paste0("Error applying ", method_label, ": ", result$error))
                return()
            }

            df_overview(result$data)

            downstream_note <- "This table is now used by the Swarm plot, Genes correlation, Heatmap, and PCA tabs."
            normalisation_status(
                if(method == "none"){
                    paste("No normalisation applied - the original loaded table is used.", downstream_note)
                } else if(method %in% c("tpm", "fpkm")){
                    if(result$dropped == 0){
                        paste0("Applied: ", method_label, ". All ", result$total, " genes matched the gene length file - none skipped. ", downstream_note)
                    } else {
                        paste0("Applied: ", method_label, ". ", result$dropped, " of ", result$total,
                               " genes were skipped (no matching entry in the gene length file) and are excluded from the normalised table. ", downstream_note)
                    }
                } else {
                    paste0("Applied: ", method_label, ". ", downstream_note)
                }
            )
        })

        output$normalisation_status <- renderText({ normalisation_status() })

    ## when nothing is selected
        output$Data_noselect_message <- renderText({"Please select a dataset above"})  

    ## display the table
        # data class: B
        output$DataTable <- DT::renderDataTable({ 
            if(is.null(df_overview())){
                datatable( data.frame(Message = "No dataset selected"), options = list(scrollX = TRUE, pageLength = 20 ))  
            } else {
                datatable(df_overview(), options = list(scrollX = TRUE, pageLength = 20 )) 
            }
        })

        # data class: A
        output$Count_data_DataTable <- DT::renderDataTable({ 
            if(is.null(df_overview())){
                datatable( data.frame(Message = "No dataset selected"), options = list(scrollX = TRUE, pageLength = 20 ))  
            } else {
                datatable(df_overview(), options = list(scrollX = TRUE, pageLength = 20 )) 
            }
        })

    ## return the data table
        return(df_overview)

    ##

}