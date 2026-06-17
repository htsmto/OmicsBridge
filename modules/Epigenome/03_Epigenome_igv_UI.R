Epigenome_igv_UI <- function(ns){
    box(title='Profile Plot', width=12, status='primary', solidHeader = TRUE,
        fluidRow(
            column(4, 
                box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                    fluidRow( 
                        column(12, selectInput(ns('igv_gneome_selection'), 'Choose genome:', choices=c('hg38', 'hg19', 'mm10', 'mm39'), selected='hg38')),
                        column(12, htmlOutput(ns("igv_data_select"))),
                        column(12, 
                            div(id='filterin_dropdown',
                                dropdownButton( 
                                    fluidRow(
                                        column(6, htmlOutput(ns("igv_data_DataFrom"))),
                                        column(6, htmlOutput(ns("igv_data_Experiment")))
                                    ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "500px",  tooltip = tooltipOptions(title = "Dataset filtering")
                                )
                            ) 
                        ),
                        column(12, h2('')),
                        column(12, 
                            fluidRow(
                                column(12, h5('Selected dataset detail:')),
                                column(12, verbatimTextOutput(ns('igv_Dataset_detail'))),
                            ),
                            fluidRow(
                                h3(''),
                                column(12, actionButton(ns("igv_data_add"), "View in IGV", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                            )
                        )
                    )
                )
            ),
            column(8,
                box(width=12, title='Plot', status='danger', collapsible = TRUE,
                    fluidRow(
                        column(12, withSpinner(igvShiny::igvShinyOutput(ns("igv"), height = "1000px"), type = 5, color = "#0dc5c1") )
                    )
                )
            )
        )
    )
}