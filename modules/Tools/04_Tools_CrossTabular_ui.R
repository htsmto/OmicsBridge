tools_crosstabular_UI <- function(ns){
    box(width=12, status='primary',  solidHeader = TRUE, title='Cross-tabulation analysis',
    # h3('Cross-tabulation analysis'),
    fluidRow(
        column(5,
            fluidRow(
                # Input table
                column(12, 
                    box(width=12, title='Table contents', status='info',collapsible = TRUE,
                        fluidRow(
                            column(12, helpText("Input the group names and values to create a 2x2 table. Then you can perform statistic test and plot the results.")),
                            column(12, verbatimTextOutput(ns("cross_table_status_input"))),
                            column(12, h4(strong('Group Names'))),
                            column(6, textInput(ns("Cross_tabulation_Row1"), "Row - Group 1")),
                            column(6, textInput(ns("Cross_tabulation_Row2"), "Row - Group 2")),
                            column(6, textInput(ns("Cross_tabulation_col1"), "Column - Group 1")),
                            column(6, textInput(ns("Cross_tabulation_col2"), "Column - Group 2")),
                            column(12, h4(strong('Values'))),
                            column(6, numericInput(ns("Cross_tabulation_val1"), "Row-Group1 & Column-Group1", 0, min=0)),
                            column(6, numericInput(ns("Cross_tabulation_val2"), "Row-Group1 & Column-Group2", 0, min=0)),
                            column(6, numericInput(ns("Cross_tabulation_val3"), "Row-Group2 & Column-Group1", 0, min=0)),
                            column(6, numericInput(ns("Cross_tabulation_val4"), "Row-Group2 & Column-Group2", 0, min=0)),
                            column(12,h3("")),
                            hr(),
                        )
                    )
                ),

                # show the input table
                column(12,    
                    box(width=12,title='2x2 Table', status='warning',collapsible = TRUE,
                        fluidRow(column(12, verbatimTextOutput(ns("cross_table_status")))),
                        fluidRow(column(12, dataTableOutput(ns("Cross_tabulation_table"))))
                    )
                ),

                # show the statistic test result
                column(12,
                    box(width=12, title='Statistic test', status='danger',collapsible = TRUE,
                        fluidRow(
                        column(12, radioButtons(ns('cross_table_Statistic_method'), "Choose a method", choices=c('Chi-squre test'='A', "Fisher's exact test" = 'B'), selected='A')),
                        column(12, verbatimTextOutput(ns("cross_table_Statistic"))),
                        )                          
                    )
                )
            )
        ),

        column(7,
            # output plot
            box(width=12, title='Plot',status='danger',collapsible = TRUE,
                fluidRow(
                    column(12, radioButtons(ns('Cross_tabulation_plot_method'), 'Choose the Plot method', choices=c(
                        'Calculate the percentile (stack bar plot)'='A', 
                        'Use the original count (stack bar plot)'='C',
                        'Use the original count (dodge bar plot)'='D'
                        ), selected='A')
                    ),
                    column(10, verbatimTextOutput(ns("Cross_tabulation_plot_status"))),
                    column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                            column(6, sliderInput(ns('Cross_tabulation_plot.width'), 'Fig width (Feature plot)', min=300, max=3000, value=500, step=10)),
                            column(6, sliderInput(ns('Cross_tabulation_plot.height'), 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10)),
                            column(6, sliderInput(ns('Cross_tabulation_plot_X_label.font.size'), 'X label font size', min=1, max=15, value=5, step=1)),
                            column(6, sliderInput(ns('Cross_tabulation_plot_Y_label.font.size'), 'Y label font size', min=1, max=15, value=5, step=1)),
                            column(6, sliderInput(ns('Cross_tabulation_plot_XY_title.font.size'), 'Y title font size', min=1, max=15, value=5, step=1)),
                            column(6, sliderInput(ns('Cross_tabulation_plot_legend_size'), 'Legend font size', min=1, max=15, value=5, step=1)),
                        ),
                        fluidRow(
                            column(6, colourpicker::colourInput(ns('Cross_tabulation_plot_col1_colour'), 'Colour for Column-Group 1', value='#0D00FF')),
                            column(6, colourpicker::colourInput(ns('Cross_tabulation_plot_col2_colour'), 'Colour for Column-Group 2', value='#92D113')),
                        ),
                        fluidRow(
                            column(6, materialSwitch(ns('Cross_tabulation_plot_col2_colour_while_background'), 'Use white background', value=FALSE, status = "success") )
                        ),
                        fluidRow(
                            column(6, materialSwitch(ns('Cross_tabulation_plot_rotate_x'), 'Rotate X labels', value=FALSE, status = "success") ),
                            conditionalPanel(condition = paste0("input['", ns("Cross_tabulation_plot_rotate_x"), "'] == true"), 
                                column(6, numericInput(ns("Cross_tabulation_plot_rotate_x_angle"), "Angle", 45, min=0))
                            )
                        ),
                        circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                    ),
                    column(12, withSpinner(plotOutput(ns("Cross_tabulation_plot"),  width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                )
            )
        ),
    )
    )
}