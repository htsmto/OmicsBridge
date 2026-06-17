DataOverview_MainPlot_ui <- function(ns){
    box(collapsible=TRUE, status='danger', width=12,  title = div(style = "color: #c7163c; font-weight: bold;", "Main plot"), 
        tabsetPanel(
            tabPanel(strong("Scatter Plot"),
                fluidRow(
                    column(12, h4('')),
                    column(10, verbatimTextOutput(ns('Gene_ex_status'))),
                    column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6,sliderInput(ns('fig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput(ns('fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(ns('pt.size'), 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                                column(6, sliderInput(ns('high.pt.size'), 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                                column(6, sliderInput(ns('high.label.size'), 'Highlighted labels size', min=0.1, max=5, value=0.9, step=0.1)),
                                column(6, sliderInput(ns('label.font.size'), 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                                column(6, sliderInput(ns('title.font.size'), 'X/Y title font size', min=1, max=15, value=4, step=0.1)),
                                column(6, sliderInput(ns('label.overlap.level'), 'Label overlap level', min=0, max=300, value=50, step=1))
                                # column(4, sliderInput('graph.title.font.size', 'Graph title font size', min=1, max=40, value=10, step=1))
                            ),
                            fluidRow(
                                column(12, h5('Graph display area:')),
                                column(3, numericInput(ns('main_plot_xlim_1'), 'Min X-axis:', value=NA, step=0.1)),
                                column(3, numericInput(ns('main_plot_xlim_2'), 'Max X-axis:', value=NA, step=0.1)),
                                column(3, numericInput(ns('main_plot_ylim_1'), 'Min Y-axis:', value=NA, step=0.1)),
                                column(3, numericInput(ns('main_plot_ylim_2'), 'Max Y-axis:', value=NA, step=0.1)),
                            ),
                            fluidRow(
                                column(5, materialSwitch(ns('while_background'), 'Use white background', value=FALSE, status='success')),
                                column(5, materialSwitch(ns('main_plot_white_back_label'), 'Use white background for labels', value=FALSE, status='success'))
                            ),circle = FALSE, status = "success", icon = icon("gear"), width = "800px", tooltip = tooltipOptions(title = "Plot Options")
                        ),
                    ),
                    column(12, h4('')),
                    column(12, withSpinner(plotOutput(ns("Gene_ex"), brush = ns("plot_brush"), width="100%", height="100%"), type=5, color='#0dc5c1'))
                )
            ),
            tabPanel(strong('Bar Plot'),
                fluidRow(
                column(12, h4('')),
                column(10, verbatimTextOutput(ns("Gene_ex_barplot_status"))),
                column(2, 
                    dropdownButton( h4(strong("Plot Options")),
                    fluidRow(
                        column(6, sliderInput(ns('Gene_ex_barplot_fig.width'), label='fig width', min=300, max=3000, value=500, step=10)),
                        column(6, sliderInput(ns('Gene_ex_barplot_fig.height'), label='fig height', min=300, max=3000, value=500, step=10)),
                        column(6, sliderInput(ns('Gene_ex_barplot_xlab.font.size'), label='X label size', min=0, max=10, value=4, step=0.1)),
                        column(6, sliderInput(ns('Gene_ex_barplot_ylab.font.size'), label='Y label size', min=1, max=10, value=4, step=0.1)),
                        column(6, sliderInput(ns('Gene_ex_barplot_graph.title.font.size'), label='Y title size', min=1, max=10, value=4, step=0.1))
                    ),
                    fluidRow( # colour for max, 0 and min values
                        column(6, colourpicker::colourInput(ns('Gene_ex_barplot_col_max'), label='Colour for the max value:', value='red')),
                        column(6, colourpicker::colourInput(ns('Gene_ex_barplot_col_min'), label='Colour for the min value:', value='blue')),
                        column(6, colourpicker::colourInput(ns('Gene_ex_barplot_col_0'), label='Colour for the 0 value:', value='white'))
                    ),
                    fluidRow(
                        # Rotate x axis lable in the bar plot
                        column(6, materialSwitch(ns('show_outliers_rotate_x'), 'Rotate x axis lable', value=TRUE, status = "success")),
                        column(6, materialSwitch(ns('Gene_ex_barplot_white_background'), 'Use white background', value=FALSE, status = "success"))
                    ),
                    circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                    )
                ),
                column(12, h4('')),
                column(12, withSpinner(plotOutput(ns("Gene_ex_barplot"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                )
            )
        )
    )
}