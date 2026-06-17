
scRNA_DataSelection_ui <- function(ns) {
    box( width=12, title='Dataset selection', status='info', solidHeader = TRUE, collapsible=TRUE,
        fluidRow( 
            column(6, htmlOutput(ns("scRNA_data_select"))) ,
            column(6, h5('Dataset detail:'), 
            withSpinner(verbatimTextOutput(ns('scRNA_data_Dataset_detail')), type = 5, color = "#0dc5c1" )
            )
        )
    )
}
