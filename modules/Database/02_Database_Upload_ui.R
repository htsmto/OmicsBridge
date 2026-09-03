database_upload_UI <- function(ns){
    box(width=12,  collapsible=TRUE, title='Data upload',status='success', solidHeader = TRUE,

        ## Section1: Upload a file
        fluidRow( 
            column(12, h4(strong('1. Upload a file'))),
        ),
        fluidRow( 
            column(5, 
                helpText(strong("Please upload the data file (.csv/.tsv/.txt/.rds) regarding the format (Data Class).")),
                fileInput(ns("upload_file"), "Upload data file", accept = c(".csv", ".tsv", ".txt", ".rds", ".bam", '.bw', '.bed', '.narrowPeak')),
                conditionalPanel(condition = paste0("input['", ns("upload_Data_Class"), "'] == 'F'"),
                    helpText(strong("Uploading large size files like bam files may take a while or even fail due to the file size limit depending on your computer specifications.")),
                )
            ),
            column(5,
                conditionalPanel(condition = paste0("input['", ns("upload_Data_Class"), "'] == 'F'"),
                    helpText(strong("Please upload the corresponding .bai file as well.")),
                    fileInput(ns("upload_bai_file"), "Upload .bai file", accept = c(".bai"))
                )
            ),
            column(1, h4('')),
            column(1, 
                div(id='help',
                dropdownButton( 
                    fluidRow(
                        column(12, h4(strong("Quick upload guide"))),
                        column(12, 
                            helpText(HTML("
                            - Make sure that the column name containing gene names is set 'id'. <br>
                            - The boxes with * are mandatory. <br>
                            - Avoid special characters; use only alphabets, numbers, underscores and dots. <br>
                            - Dataset name must be unique. <br>
                            - In case uploading a count data, the columns must be set to (Sample name)_Rep#. See the wiki for more information. <br>
                            "))
                        ),
                    ), circle = TRUE, status = "success", icon = icon("question"), width = "900px",  tooltip = tooltipOptions(title = "Help"), right = TRUE
                )) 
            )
        ),

        ## Section 2: dataset information
        fluidRow( 
            column(12, h4(strong("2. Fill in the dataset information"))), 
        ),
        fluidRow(  # name, experiment, data.from
            column(4, textInput(ns("upload_dataset_name"), HTML("Dataset name * <br/> Ex.) WT vs KO in Cell A"))), 
            column(4, textInput(ns("upload_Experiment"), HTML("Experiment name * <br/> Ex.) Gene A KO RNAseq"))), 
            column(4, textInput(ns("upload_data_from"), HTML("Data from * <br/> Ex.) Public data, Student A") ))
        ),
        fluidRow( # data type (if 'others' is selected, show a text input), cell line, when
            column(4, 
                htmlOutput(ns("upload_data_type_select")),
                uiOutput(ns("upload_data_type")),
            ),
            column(4, textInput(ns("upload_cell_line"), HTML("Cell line, Data source <br/> Ex.) THP1, PBMC"))), 
            column(4, textInput(ns("upload_when"), HTML("When <br/> Ex.) 2025-01"))) 
        ),
        fluidRow( 
            column(6, selectInput(ns('upload_Data_Class'), HTML('Data Class * <br/> Please choose one.'), 
                c('A: Count data/Expression matrix'='A', 
                    'B: Comparison data (any table containing log fold change values)'='B',
                    'C: single cell RNA'='C', 
                    'D: bed/narrowPeak file from ATAC/ChIP/CUT&RUN etc'='D', 
                    'E: bigwig file'='E', 
                    'F: bam file (and bai file)'='F' ), 
                selected='B')
            ), 
            column(6,
                conditionalPanel(condition = paste0("input['", ns("upload_Data_Class"), "'] == 'B'"), 
                    fluidRow(
                        column(12, textInput(ns("upload_Control_group"), HTML("Control group name <br/> Ex.) Untreated, WT"))), 
                        column(12, textInput(ns("upload_Treatment_group"), HTML("Treatment group name <br/> Ex.) Treated, KO")))
                    )
                ),
                conditionalPanel(condition = paste0("input['", ns("upload_Data_Class"), "'] == 'A'"),
                    fluidRow(
                        column(12, h3('\n')),
                        column(12, h3('\n')),
                        column(12, h5(span('\nIn case of uploading a count data, please make sure that the columns are set to "(Sample name)_Rep#". See wiki for more information', style="color: red;"))) ,
                    )
                )
            )
        ),
        fluidRow( 
            column(8, textAreaInput(ns("upload_description"), "Description")) 
        ),

        ## upload button
        fluidRow( 
            column(12, h4(strong("3. Register the dataset")))
        ),
        fluidRow(
            column(3, 
                fluidRow(
                    column(6, actionButton(ns("upload_data"), 'Register dataset',style="width:240px; color: #ffffff; background-color: #387842; ")),
                    # column(6, actionButton(ns("upload_reset"), 'Reset',style="width:240px; color: #ffffff; background-color: #387842; "))
                ),
            ),
            column(6, verbatimTextOutput(ns('status_upload')))
        ),

        ## data preview
        fluidRow(
            column(12, h4(strong('4. Preview')))
        ),
        fluidRow(
            column(9, verbatimTextOutput(ns('data_preview_status')))
        ),
        fluidRow(
            column(12, helpText('The header of the uploaded data will be shown in the table below. Please make sure the data is in the correct format before uploading.')),
            column(12, dataTableOutput(ns("data_preview")))
        )
    )
}
