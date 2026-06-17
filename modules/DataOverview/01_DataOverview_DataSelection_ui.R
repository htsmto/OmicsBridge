dataoverview_dataselection_UI <- function(ns){
  box(width=12, collapsible=TRUE, title=strong('Dataset Selection'), status = "info", solidHeader = TRUE,
    fluidRow(
        # Data selection button and filter
        column(6, 
            fluidRow(
                column(12, htmlOutput(ns("Dataset_select"))),
                column(4, 
                    div(id='filterin_dropdown',
                        dropdownButton( 
                            fluidRow(
                                column(12, h4(strong("Dataset filtering"))),
                                column(3, htmlOutput(ns("Seuqenced_by"))), 
                                column(5, htmlOutput(ns("Experiments"))), 
                                column(4, htmlOutput(ns("Data_type"))) 
                            ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "1300px",  tooltip = tooltipOptions(title = "Dataset filtering")
                        )
                    )
                ),
                column(4, 
                    actionButton(ns('reload_database'), 'Reload your datasets list', style="color: #ffffff; background-color: #1C9600; border-color: #2A8708")
                )
            )
            

        ),

        # Dataset detail
        column(6, 
            h5(strong('Dataset detail:')),
            withSpinner(verbatimTextOutput(ns('Dataset_detail')), type=5, color='#0dc5c1') 
        )
    )

  )
}
