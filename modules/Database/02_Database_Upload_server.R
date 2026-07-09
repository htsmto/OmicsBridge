# =============================================================================
# Database - Dataset Upload Server
# File: modules/Database/02_Database_Upload_server.R
# Purpose: Handles registration of new omics datasets into the master database.
#          Accepts the expression TSV and an optional metadata file, validates
#          them, copies to the data directory, and appends a row to Database.tsv.
# Edit this file when: changing upload validation, the database TSV schema,
#                       or the file naming convention for uploaded datasets.
# =============================================================================

database_upload_Server <- function(input, output, session) {

    ## load the full database
        Dataset <- reactiveVal(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))

    ## Status. Initial variants.
        status <- reactiveVal('No file uploaded yet.')
        Preview_data <- reactiveVal(NULL)
        Dataset_name <- reactiveVal(NULL)
        Experiment_name <- reactiveVal(NULL)
        Data_from <- reactiveVal(NULL)
        Data_type <- reactiveVal(NULL)
        Cell_line <- reactiveVal(NULL)
        When <- reactiveVal(NULL)
        Data_Class <- reactiveVal(NULL)
        Control_group <- reactiveVal(NULL)
        Treatment_group <- reactiveVal(NULL)
        Description <- reactiveVal(NULL)
        Data_path <- reactiveVal(NULL)
        file_name <- reactiveVal(NULL)

    # Flags
        file_uploaded <- reactiveVal(FALSE)


    ## show the status text
        output$status_upload <- renderText(status())

    ## data type selection
        # render the data type selection dropdown based on the existing data types in the database
        output$upload_data_type_select <- renderUI({
          selectInput(session$ns("upload_data_type_select_select"), 
            HTML("Data type * <br/> Ex.) Count data, DEG data, scRNA"), 
            choices=c('--Select from the below--', unique(Dataset()$Data.type), 'Other'), 
            selected='--Select from the below--')
        })

        output$upload_data_type <- renderUI({
          if(length(input$upload_data_type_select_select) > 0){
            if(input$upload_data_type_select_select == 'Other'){
              textInput(session$ns("upload_data_type_manual"), "Write the data type here *")
            }
          }
        })

    ## Show a preview of the dataset # column(12, dataTableOutput(ns("data_preview")))
        output$data_preview <- renderDataTable({
            if(!is.null(Preview_data())){
                datatable(head(Preview_data(), 10), options = list(pageLength = 10, scrollX = TRUE))
            }else{
                datatable(data.frame(Message = "No data to preview."), options = list(dom = 't'))
            }
        })

    ## When a file is uploaded, read the file and show a preview if the file is csv/tsv/txt
        observeEvent(input$upload_file, {
             Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
            req(input$upload_file)
            file <- input$upload_file

            # check the file extension
            ext <- tools::file_ext(file$datapath)
            if(ext %in% c('csv', 'tsv', 'txt')){
                # read the file. If error occurs, show the error message in the preview table and also show the alert message
                if(ext == 'csv'){
                    df_upload <- tryCatch({
                        read.csv(file$datapath, header = TRUE, check.names = FALSE)
                    }, error = function(e){
                        status(paste("Error in reading the file:", e$message))
                        show_alert(title = "Error", text = paste("Error in reading the file:", e$message), type = "error")
                        file_uploaded(FALSE)
                        Preview_data(NULL)
                        Data_path(NULL)
                        file_name(NULL)
                        return(NULL)
                    })
                }else if(ext %in% c('tsv', 'txt')){
                    df_upload <- tryCatch({
                        read.table(file$datapath, header = TRUE, check.names = FALSE, sep = '\t')
                    }, error = function(e){
                        status(paste("Error in reading the file:", e$message))
                        show_alert(title = "Error", text = paste("Error in reading the file:", e$message), type = "error")
                        file_uploaded(FALSE)
                        Preview_data(NULL)
                        Data_path(NULL)
                        file_name(NULL)
                        return(NULL)
                    })
                }

                # the column name containing gene names is set 'id'. Check if the column 'id' exists. If not, show the error message in the preview table and also show the alert message
                if(!is.null(df_upload)){
                    if(!'id' %in% colnames(df_upload)){
                        show_alert(title = "Error", text = "The column containing gene names must be named 'id'. Please check your file and upload again.", type = "error")
                        status("Error: The column containing gene names must be named 'id'. Please check your file and upload again.")
                        Preview_data(NULL)
                        Data_path(NULL)
                        file_name(NULL)
                        file_uploaded(FALSE)
                    }else{
                        status("File uploaded successfully. Please check the preview and fill in the dataset information before uploading to the database.")
                        Preview_data(df_upload)
                        Data_path(file$datapath)
                        file_name(file$name)
                        file_uploaded(TRUE)
                    }
                }
            }else if(ext %in% c('rds', 'bam', 'bw', 'bed', 'narrowPeak')){ # in case of other file types like rds, just show the file upload status and do not show the preview
                status("File uploaded successfully. This file type does not support preview. \nPlease fill in the dataset information before uploading to the database. \nNote: Large files like bam files may take a while to upload or even fail depending on your computer specifications.")
                Preview_data(NULL)
                Data_path(file$datapath)
                file_name(file$name)
                file_uploaded(TRUE)
            }else{
                status("Error: Unsupported file type. Please upload a csv, tsv, txt, rds, bam, bw, bed or narrowPeak file.")
                show_alert(title = "Error", text = "Unsupported file type. Please upload a csv, tsv, txt, rds, bam, bw, bed or narrowPeak file.", type = "error")
                Preview_data(NULL)
                Data_path(NULL)
                file_uploaded(FALSE)
                file_name(NULL)
            }
        })
    
    ## information input
        observe({
            Dataset_name(input$upload_dataset_name)
            Experiment_name(input$upload_Experiment)
            Data_from(input$upload_data_from)
            Data_type(if(isTRUE(input$upload_data_type_select_select == 'Other')) {
                if(is.null(input$upload_data_type_manual)) '' else input$upload_data_type_manual
            } else {
                input$upload_data_type_select_select
            })
            Cell_line(input$upload_cell_line)
            When(input$upload_when)
            Data_Class(input$upload_Data_Class)
            Control_group(input$upload_Control_group)
            Treatment_group(input$upload_Treatment_group)
            Description(input$upload_description)
        })

    ## upload
        # upload botton
        observeEvent(input$upload_data, {
            # check the file flag
            if(!file_uploaded()){
                show_alert(title = "Error", text = "No file uploaded or upload failed. Please upload a file before clicking the upload button.", type = "error")
                status("Error: No file uploaded or upload failed. Please upload a file before clicking the upload button.")
                return(NULL)
            }

            # show the upload info in the status
            status_message <- paste0(
                "Dataset name*: ", Dataset_name(), "\n",
                "Experiment name*: ", Experiment_name(), "\n",
                "Data from*: ", Data_from(), "\n",
                "Data type*: ", Data_type(), "\n",
                "Cell line: ", Cell_line(), "\n",
                "When: ", When(), "\n",
                "Data Class*: ", Data_Class(), "\n",
                "Control group: ", Control_group(), "\n",
                "Treatment group: ", Treatment_group(), "\n",
                "Description: ", Description(), "\n"
            )


            # check the dataset name uniqueness
            if(length(Dataset_name()) != 0 && Dataset_name() %in% Dataset()$Dataset){
                show_alert(title = "Error", text = "Dataset name already exists. Please choose a unique dataset name.", type = "error")
                status(paste0("Error: Dataset name already exists. Please choose a unique dataset name. \n", "\nYou are about to upload the dataset with the following information: \n", status_message))
                return(NULL)
            }

            # mandatory fields check
            if(!nzchar(trimws(Dataset_name())) || !nzchar(trimws(Experiment_name())) || !nzchar(trimws(Data_from())) || !nzchar(trimws(Data_type())) || length(Data_Class()) == 0 || Data_type() == '--Select from the below--'){
                show_alert(title = "Error", text = "Please fill in all the mandatory fields marked with * before clicking the upload button.", type = "error")
                status(paste0("Error: Please fill in all the mandatory fields marked with * before clicking the upload button. \n", "\nYou are about to upload the dataset with the following information: \n", status_message))
                return(NULL)
            }

            # if case of a count data, check if the columns are set to Sample_Rep#, show an error message and stop.
            if(Data_Class() == 'A'){
                pattern <- "^\\S+_Rep[0-9]+$"
                file_colnames <- colnames(Preview_data())
                if(!all(grepl(pattern, file_colnames[file_colnames != 'id']))){
                    show_alert(title = "Error", text = "For count data, the columns must be set to (Sample name)_Rep#. See the wiki for more information.", type = "error")
                    status(paste0("Error: For count data, the columns must be set to (Sample name)_Rep#. See the wiki for more information. \n", "\nYou are about to upload the dataset with the following information: \n", status_message))
                    return(NULL)
                }
            }

            # check if there are any special characters in the dataset name, the experiment name, the data from and the data type. Only alphabets, numbers, underscores, dots (except the first character), space and () is acceptable.
            special_char_pattern <- "^[A-Za-z][A-Za-z0-9._() ]*$"
            if(!grepl(special_char_pattern, Dataset_name()) || !grepl(special_char_pattern, Experiment_name()) || !grepl(special_char_pattern, Data_from()) || !grepl(special_char_pattern, Data_type())){
                show_alert(title = "Error", text = "Special characters are not allowed. Please use only alphabets, numbers, underscores, dots (except the first character), space and ().", type = "error")
                status(paste0("Error: Special characters are not allowed. Please use only alphabets, numbers, underscores, dots (except the first character), space and (). \n", "\n", status_message))
                return(NULL)
            }

            # if all checke are passed, then proceed with the confirmation
            status(paste("You are about to upload the dataset with the following information: \n", status_message))
            confirmSweetAlert(
                session = session,
                inputId = session$ns("confirm_upload_data"),
                title = "Are you sure you want to upload the data?",
                text = "This action cannot be undone.",
                btn_labels = c("Cancel", "Upload"), # left=False, right=true, so the order of the buttons is Cancel, Upload
                btn_colors = c("#5b5d6e", "#0ba446")
            ) 
        })

        # when the upload is confirmed, save the data to the database and also save the file to the server
        observeEvent(input$confirm_upload_data, {
            req(input$confirm_upload_data)
            if(input$confirm_upload_data){

                # save the file to the server. 
                time_stamp <- as.character(Sys.time())  
                Year <- format(Sys.time(), "%Y")
                date <- format(Sys.time(), "%m.%d")
                filname <- paste0(format(Sys.time(), "%H.%M.%S"), '-', file_name() )
                save_path <- file.path('00_Expression_data_all', Year, date, filname)
                dir.create(file.path('00_Expression_data_all', Year, date), recursive=T, showWarnings = F)
                file.copy(Data_path(), save_path)

                # save the dataset information to the database
                new_entry <- data.frame( 
                    Dataset = Dataset_name(),
                    Data.type = Data_type(),
                    CellLine = Cell_line(),
                    Data.from = Data_from(),
                    When = When(),
                    Experiment = Experiment_name(),
                    Control.group = Control_group(),
                    Treatment.group = Treatment_group(),                
                    Description = Description(),
                    Data.Class = Data_Class(),
                    Path = save_path,
                    Added.When = time_stamp,
                    stringsAsFactors = FALSE
                )
                tmp <- rbind(Dataset(), new_entry)
                tmp <- tmp[order(tmp$Added.When, decreasing =T),]
                Dataset(tmp)
                write.table(Dataset(), 'data/Database.tsv', sep='\t', row.names = FALSE, quote = FALSE)

                # reset the flag
                file_uploaded(FALSE)

                # change the status
                status_message <- paste0(
                    "Dataset name*: ", Dataset_name(), "\n",
                    "Experiment name*: ", Experiment_name(), "\n",
                    "Data from*: ", Data_from(), "\n",
                    "Data type*: ", Data_type(), "\n",
                    "Cell line: ", Cell_line(), "\n",
                    "When: ", When(), "\n",
                    "Data Class*: ", Data_Class(), "\n",
                    "Control group: ", Control_group(), "\n",
                    "Treatment group: ", Treatment_group(), "\n",
                    "Description: ", Description(), "\n"
                )
                status(paste0("Dataset uploaded successfully.", "\n", "\nYou uploaded the dataset with the following information: \n", status_message))
                show_alert(title = "Success", text = "Dataset uploaded successfully.", type = "success")
            }


        })

}   
