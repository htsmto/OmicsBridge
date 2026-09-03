tools_symbolens_UI <- function(ns){
    box(width=12, status='primary',  solidHeader = TRUE, title='Convert Gene Symbols and Ensembl Gene IDs',
    fluidRow(
        column(5, 
        box(width=12,  title='Inputs and Settings', status='info',collapsible = TRUE,
            fluidRow(
                column(12, helpText(HTML("This tool converts gene symbols to Ensembl gene ids, or Ensembl gene ids to gene symbols. <br>The conversion is based on the annotation from Ensembl database. <br>Please select the species, input and output gene ID types, and enter the list of genes (line by line). Then click the 'Convert genes' button to start the conversion. <br>The conversion table and the list of converted genes will be shown on the right side."))),
                column(2, radioButtons(ns("Gene_Ensembl_spieces"), "Species", choices=c("Human"='A', "Mouse"='B'), selected="A")),
                column(4, radioButtons(ns("Gene_Ensembl_input_type"), "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='B')),
                column(4, radioButtons(ns("Gene_Ensembl_output_type"), "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A'))
            ),
            fluidRow(
                column(10, textAreaInput(ns('Gene_Ensembl_input_gene'), 'Enter genes (line by line)')),
            ),
            h4('\n'),
            fluidRow(
                column(12, verbatimTextOutput(ns('symbolens_status_input')) ),
                column(12, actionButton(ns('Gene_Ensembl_convert_start'), 'Convert genes', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
            )
        )
        ),
        column(4, 
            box(width=12, title='Conversion Table', status='danger',collapsible = TRUE,
                fluidRow(
                    column(12, verbatimTextOutput(ns('symbolens_status_table')) ),
                    column(12, withSpinner(DT::dataTableOutput(ns('Gene_Ensembl_convert_table')), type = 5, color = "#0dc5c1") ),
                    column(12, downloadButton(ns('Gene_Ensembl_convert_table_download'),"Download this table")),
                )
            )
        ),
        column(3, 
            box(width=12, title='List of Converted Genes', status='warning',collapsible = TRUE,
                fluidRow(
                column(12, verbatimTextOutput(ns('symbolens_status_result')) )
                )
            )
        )
    )
    )
}