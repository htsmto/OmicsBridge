clinical_COSMIC_ui <- function(ns){
    box(width=12,title='Cacner Gene Census (COSMIC)', status='primary',
        fluidRow(
            column(12, 
                helpText(HTML('We are using the <a href="https://cancer.sanger.ac.uk/census" target="_blank">Cancer Gene Census from COSMIC</a>. <br>
                    Please enter gene names below or select a gene set.<br>
                    If the genes are associated with cancer predisposition, they will appear in the table. Otherwise, the entire database will be displayed.')
                )
            ),
            column(12, h2('')),

            # Input
            column(3,
                box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                    fluidRow(
                        column(12, htmlOutput(ns('CGC_input_gene'))),
                        column(12, materialSwitch(ns('CGC_input_gene_from_custom_geneset'), 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                        column(12, htmlOutput(ns('CGC_input_gene_from_custom_geneset_select')) ),
                        column(12, verbatimTextOutput(ns('CGC_input_gene_status')) )
                    )
                )
            ),

            # Result table
            column(9, 
                box(width=12, title='Result Table', status='warning', collapsible = TRUE,
                    fluidRow(
                    column(12, h4('')),
                    column(12, verbatimTextOutput(ns("CGC_table_status"))),
                    column(12, withSpinner(dataTableOutput(ns("CGC_table")), type=5, color="#0dc5c1")),
                    column(12, downloadButton(ns('CGC_table_download'),"Download this table"))
                    )
                )
            ),
        )

    )    
}