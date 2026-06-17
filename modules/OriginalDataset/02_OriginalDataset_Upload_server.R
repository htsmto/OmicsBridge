# =============================================================================
# OriginalDataset (Custom Gene Sets) - Upload Server
# File: modules/OriginalDataset/02_OriginalDataset_Upload_server.R
# Purpose: Handles upload of new custom gene sets (TSV format: name + gene list)
#          and appends them to Genesets_list.tsv so they appear in all
#          gene-set selectors across the app.
# Edit this file when: changing the upload format, validation rules,
#                       or the gene set TSV schema.
# =============================================================================

original_geneset_upload_server <- function(input, output, session) {
    ## Initial variables and status
        # load the full database
            Original_geneset_list <- reactiveVal(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))

        # status
            Original_geneset_status_upload <- reactiveVal("Please fill in the form and click the button to add the geneset to the list.")

        # Show the status text
            output$Original_geneset_status_upload <- renderText(Original_geneset_status_upload())

        # Initial variants
            Geneset_name <- reactiveVal(NULL)
            Cell_line <- reactiveVal(NULL)
            Data_source <- reactiveVal(NULL)
            Genes <- reactiveVal(NULL)
            Description <- reactiveVal(NULL)

    ## Upload
        # information input
            observe({
                Geneset_name(input$Original_geneset_upload_Geneset_name) # mandatory
                Cell_line(input$Original_geneset_upload_cell_line)
                Data_source(input$Original_geneset_upload_data_generated_from)
                Genes(input$Original_geneset_upload_genes) # mandatory
                Description(input$Original_geneset_upload_description)
            })        

        # upload action
            observeEvent(input$Original_geneset_upload_data, {
                # reload the database to get the latest version (in case there are multiple users uploading at the same time)
                    Original_geneset_list(data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T,check.names = FALSE)))

                # show the upload info in the status
                    Original_geneset_status_upload(paste0("Uploading geneset: ", Geneset_name(), " ..."))

                # mandatory fields check
                    if (is.null(Geneset_name()) || Geneset_name() == "" || is.null(Genes()) || Genes() == "") {
                        Original_geneset_status_upload("Error: Geneset name and Genes are mandatory. Please fill in the required fields.")
                        show_alert(title = "Error", text = "Geneset name and Genes are mandatory. Please fill in the required fields.", type = "error")
                        return()
                    }
                
                # check for unique geneset name
                    if (Geneset_name() %in% Original_geneset_list()$Geneset.name) {
                        Original_geneset_status_upload("Error: Geneset name already exists. Please choose a unique name.")
                        show_alert(title = "Error", text = "Geneset name already exists. Please choose a unique name.", type = "error")
                        return()
                    }

                # copy the input values to new variables for easier reference
                    Geneset_name_to_add <- Geneset_name()
                    Cell_line_to_add <- Cell_line()
                    Data_source_to_add <- Data_source()
                    Genes_to_add <- unlist(strsplit(Genes(), "\n")) 
                    Description_to_add <- Description()

                # when the genes box is not empty but only contains spaces or newlines, it is considered as empty
                    if (all(grepl("^\\s*$", Genes_to_add))) {
                        Original_geneset_status_upload("Error: Genes field cannot be empty. Please provide a list of genes.")
                        show_alert(title = "Error", text = "Genes field cannot be empty. Please provide a list of genes.", type = "error")
                        return()
                    }

                # check if the geneset name contains only allowed characters (alphanumeric, underscores, dots)
                    if (!grepl("^[a-zA-Z0-9_.]+$", Geneset_name_to_add)) {
                        Original_geneset_status_upload("Error: Geneset name contains invalid characters. Please use only letters, numbers, underscores, or dots.")
                        show_alert(title = "Error", text = "Geneset name contains invalid characters. Please use only letters, numbers, underscores, or dots.", type = "error")
                        return()
                    }

                # if all checks passed, show a confirmation
                    Original_geneset_status_upload(paste0("You are about to upload the geneset: ", Geneset_name_to_add))
                    confirmSweetAlert(
                        session = session,
                        inputId = session$ns("Original_geneset_confirm_upload_data"),
                        title = "Are you sure you want to upload this geneset?",
                        text = "This action cannot be undone.",
                        btn_labels = c("Cancel", "Upload"), # left=False, right=true, so the order of the buttons is Cancel, Upload
                        btn_colors = c("#5b5d6e", "#c65311")
                    ) 
            })

        # once it is confirmed
            observeEvent(input$Original_geneset_confirm_upload_data, {
                # copy the input values to new variables for easier reference
                    Geneset_name_to_add <- Geneset_name()
                    Cell_line_to_add <- Cell_line()
                    Data_source_to_add <- Data_source()
                    Genes_to_add <- unlist(strsplit(Genes(), "\n")) 
                    Description_to_add <- Description()
                    time_stamp <- as.character(Sys.time())  

                # add the new geneset to the database
                    new_geneset <- data.frame( # Geneset.name	Description	Cell.type	Data.source	Genes	Added.When
                        Geneset.name = Geneset_name_to_add,
                        Description = Description_to_add,
                        Cell.type = Cell_line_to_add,
                        Data.source = Data_source_to_add,
                        Genes = paste(Genes_to_add, collapse = ", "), # store genes as a comma-separated string
                        Added.When = time_stamp,
                        stringsAsFactors = FALSE
                    )
                
                    show_alert(title = "Success", text = paste0("Geneset '", Geneset_name_to_add, "' uploaded successfully."), type = "success")
                    updated_geneset_list <- rbind(Original_geneset_list(), new_geneset)
                    # sort by Added.When in descending order
                    updated_geneset_list <- updated_geneset_list[order(updated_geneset_list$Added.When, decreasing =T),]
                    Original_geneset_list(updated_geneset_list)
                    Original_geneset_status_upload(paste0("Geneset '", Geneset_name_to_add, "' uploaded successfully."))
                
                # save the updated database to the file
                        
                    write.table(Original_geneset_list(), 'data/Genesets_list.tsv', sep='\t', row.names=FALSE, quote=FALSE)

            })
}