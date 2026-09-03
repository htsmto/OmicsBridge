DatasetsCompare_DataSelection_UI <- function(ns){
    fluidRow(
        column(12, helpText(HTML("In this section, you can compare the multiple dataset with the same data type (ex. DEG analysis datasets) to see the overall similarity and difference between them. <br>First, please select the data type you want to compare. Then, select the datasets for comparison."))),

        # data type selection
        column(6, htmlOutput(ns("choose_data_type"))),
        column(2, 
            h3('\n'),
            actionButton(ns('Reload_your_databse'), 'Refresh list', style="color: #ffffff; background-color: #ee9d29; border-color: #e48803")
        ),
        column(4, h4('')),

        # Status show
        column(12, h5(strong('Select the datasets to compare below:'))),
        column(12, verbatimTextOutput(ns('Compare_dataset_selection_status'))),

        # dataset selection
        column(12, h4('\n')),
        column(12, fluidRow( column(12, dataTableOutput(ns("all_dataset"))))),

        # dataset filtering button
        column(12, 
            div(id='filterin_dropdown',
                dropdownButton( 
                    fluidRow(
                        column(6,htmlOutput(ns("Compare_dataset_filtering_Data_from"))),
                        column(6,htmlOutput(ns("Compare_dataset_filtering_Experiment")))
                    ), label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "1200px",  tooltip = tooltipOptions(title = "Filtering")
                )
            )
        )
    )   
}