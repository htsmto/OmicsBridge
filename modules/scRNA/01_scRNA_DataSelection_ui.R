
scRNA_DataSelection_ui <- function(ns) {
    box( width=12, title='Dataset Selection', status='info', solidHeader = TRUE, collapsible=TRUE,
        fluidRow(
            column(4, htmlOutput(ns("scRNA_data_select"))) ,
            column(2, h5(' '), actionButton(ns('reload_database'), 'Refresh list', style="color: #ffffff; background-color: #1C9600; border-color: #2A8708")),
            column(6, h5('Dataset detail:'),
            withSpinner(verbatimTextOutput(ns('scRNA_data_Dataset_detail')), type = 5, color = "#0dc5c1" )
            )
        )
    )
}
