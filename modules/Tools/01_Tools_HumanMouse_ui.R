tools_humanmouse_UI <- function(ns){
    box(width=12, status='primary',  solidHeader = TRUE, title='Convert Huamns genes with Mouse genes',
        fluidRow(
            column(5,
            box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                fluidRow(
                    column(12, helpText(HTML("This tool converts human genes to mouse genes, or mouse genes to human genes. <br>The conversion is based on the ortholog mapping from Ensembl database. <br>Please select the conversion direction, input and output gene ID types, and enter the list of genes (line by line). Then click the 'Convert genes' button to start the conversion. <br>The conversion table and the list of converted genes will be shown on the right side."))),
                    column(12, radioButtons(ns("human_mouse_convert_direction"), "Human <=> Mouse direction", choices = c('Convert mouse genes to human genes' = 'A', 'Convert human genes to mouse genes' = 'B'), selected='B')),
                    column(6, radioButtons(ns("human_mouse_convert_input_type"), "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A')),
                    column(6, radioButtons(ns("human_mouse_convert_output_type"), "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A')),
                    column(10, textAreaInput(ns('human_mouse_convert_input_gene'), 'Enter genes (line by line)')),
                    column(12, h4('\n')),
                    column(12, verbatimTextOutput(ns('status_input'))), 
                    column(12, h4('\n')),
                    column(4, actionButton(ns('human_mouse_convert_start'), 'Convert genes', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                )
            )
            ),
            column(4,
            box(width=12, title='Conversion Table', status='danger', collapsible = TRUE,
                fluidRow(
                column(12, verbatimTextOutput(ns('status_table'))),
                column(12, withSpinner(DT::dataTableOutput(ns('human_mouse_convert_table')), type = 5, color = "#0dc5c1") ),
                column(12, downloadButton(ns('human_mouse_convert_table_download'),"Download this table")),
                )
            )
            ),
            column(3,
            box(width=12, title='List of converted genes', status='warning', collapsible = TRUE,
                fluidRow(column(12, verbatimTextOutput(ns('status_result')) ))
            )
            )
        )
    )
}