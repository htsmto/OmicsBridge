clinical_DataSelection_ui <- function(ns){
    box(width=12, title='Data Selection', status='info', solidHeader = TRUE,
        fluidRow( 
            # selection dropdown and the reload button
            column(4, 
                fluidRow(
                    column(12, htmlOutput(ns("Clinical_data_select"))),
                    column(4, actionButton(ns("Clinical_data_reload"), "Refresh list", style="color: #ffffff; background-color: #1C9600; border-color: #2A8708"))
                )
                
            ) ,

            # show the dataset detail
            column(8, 
                fluidRow(
                    column(12, h5('Dataset detail:')),
                    column(12, withSpinner(verbatimTextOutput(ns('Clinical_Dataset_detail')), type = 5, color = "#0dc5c1" ))
                )
            )
        )
    )    
}