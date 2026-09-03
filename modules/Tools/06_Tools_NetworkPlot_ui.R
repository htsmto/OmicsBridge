tools_networkplot_UI <- function(ns){
    box(width=12, status='primary',  solidHeader = TRUE, title='Network Plot',
        # h3('Network plot'),
        fluidRow(
            # Input
            column(4,
                box(width=12, title='Input Data',collapsible = TRUE, status='info',
                    fluidRow(
                        column(12, helpText(HTML("The input file should be a three-column table: 'from', 'to' and 'weight' columns. <br>'from' and 'to' are the node names. 'weight' is the edge weight (numeric).")) ),
                        column(12, verbatimTextOutput(ns("Network_input_table_visNet_status_input"))),
                        column(12, fileInput(ns("Network_input_file"), "Upload a TSV file", accept = c(".tsv")) ),
                        column(12, materialSwitch(ns("Network_input_example"), 'Use example data', value=FALSE,  status='info') )
                    ),
                ),
                box(width=12, title='Input Data Table',collapsible = TRUE, status='warning',
                    fluidRow(
                        column(12, helpText('Here is the input data table. You can check if the data is loaded correctly.') ),
                        column(12, verbatimTextOutput(ns("Network_input_table_visNet_status_table"))),
                        column(12, dataTableOutput(ns("Network_input_table"))),
                        column(12, h4(''))
                    )
                )
            ),

            # Plot
            column(8,
                box(width=12, title='Plot',collapsible = TRUE,status='danger',
                    fluidRow(
                        column(10, verbatimTextOutput(ns("Network_input_table_visNet_status_plot"))),
                        column(2, 
                            dropdownButton( h4(strong("Graph Settings")),
                                fluidRow(
                                column(6, selectInput(ns("Network_input_shape_from"), "Node shape (From)", c('ellipse', 'circle', 'database', 'box', 'text', 'dot', 'star', 'triangle', 'triangleDown', 'square'), selected='ellipse')),
                                column(6, selectInput(ns("Network_input_shape_to"), "Node shape (To)", c('ellipse', 'circle', 'database', 'box', 'text', 'dot', 'star', 'triangle', 'triangleDown', 'square'), selected='circle')),
                                column(6, colourpicker::colourInput(ns("Network_input_color_from"), "Node colour (From)", value='#F7AFAF' )),
                                column(6, colourpicker::colourInput(ns("Network_input_color_to"), "Node colour (To)", value='#B2E9FF' )),
                                column(12, materialSwitch(ns("Network_input_arrow"), "Show direction", value=FALSE,  status='info' )),
                                ),circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Graph Settings")
                            ),
                        ),
                        column(12, h4('')),
                        column(12, withSpinner(visNetwork::visNetworkOutput(ns("Network_input_table_visNet") , width = "100%", height = "1000px"), type = 5, color = "#0dc5c1") )
                    )
                )
            )
        )
    )
}