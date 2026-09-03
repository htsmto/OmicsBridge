clinical_ExpressionCompare_ui <- function(ns){
    fluidRow(
        # Inputs and Settings
        column(12, 

            box(width=12, title='Inputs and Settings', status='info', collapsible=TRUE,
                fluidRow(

                    # gene input
                    column(4, 
                        fluidRow(
                            column(12, htmlOutput(ns('Expression_subtype_genes'))),
                            column(12, materialSwitch(ns('Expression_subtype_genes_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                            column(12, htmlOutput(ns('Expression_subtype_genes_from_custom_geneset_select'))),
                            # show the number of the input 
                            column(12, verbatimTextOutput(ns('Expression_subtype_genes_status')))
                        )
                    ),

                    # grouping category selection
                    column(4, 
                        fluidRow(
                            column(12, htmlOutput(ns('Expression_subtype_groupBy')) ),
                            column(12, verbatimTextOutput(ns('Expression_subtype_subtype_number')) ),
                            column(12, h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: red;"))),
                            column(12, materialSwitch(ns('Expression_subtype_choose_two_subtypes_only'), 'Compare only two subtypes', value=FALSE, status='info') ),
                            column(12, verbatimTextOutput(ns('Expression_subtype_choose_two_subtypes_only_select_status'))),
                            column(12, htmlOutput(ns('Expression_subtype_choose_two_subtypes_only_select')))
                        )
                    ),

                    # start 
                    column(2, 
                        fluidRow(
                            column(12, h3('') ),
                            column(12, actionButton(ns('Expression_subtype_start'), 'Start comparing',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                        )
                    ),
                    column(1, h4('')),

                    # help
                    column(1,
                        div(id='help',
                            dropdownButton( 
                                fluidRow(
                                    column(12, h4(strong("Quick guide"))),
                                    column(12, helpText(
                                        HTML("
                                            0. Select a cohort.<br>
                                            1. Set the input. <br>
                                            2. Select a category for grouping the samples.<br>
                                            3. Click the 'Start comparing'. A test result (table) will be shown in below. <br>
                                            4. By clicking a gene (row) in the table, a box plot (by default) will be displayed in the 'Plots' section.<br>
                                        "))
                                    ),
                                ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                            ),
                        ) 
                    )
                ),

                # status
                fluidRow(
                    column(8, verbatimTextOutput(ns('Expression_subtype_status')))
                )
            )
        ),

    # Results
    # table
    column(4,
        box(width=12, title='Test Results', status='warning', collapsible=TRUE,
            fluidRow(
                column(12, h4('') ),
                column(12, verbatimTextOutput(ns('Expression_subtype_table_status')) ),
                column(12, withSpinner(dataTableOutput(ns("Expression_subtype_table")), type = 5, color = "#0dc5c1" )),
                column(12, downloadButton(ns('Expression_subtype_table_download'),"Download this table") )
            )
        )
    ),

    # Plots
    column(8, 
        box(width=12, title='Plot', status='danger', collapsible=TRUE,
            fluidRow(
                column(12, verbatimTextOutput(ns('Expression_subtype_note'))), 
                column(10, radioButtons(ns('Expression_subtype_figtype'), 'Plot type', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A', inline=TRUE) ),
                column(2,
                    dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                            column(6, sliderInput(ns('Expression_subtype_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                            column(6, sliderInput(ns('Expression_subtype_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                            conditionalPanel(
                                condition = paste0("input['", ns('Expression_subtype_figtype'), "'] == 'C' || input['", ns('Expression_subtype_figtype'), "'] == 'D'"),
                                column(6, sliderInput(ns('Expression_subtype_dot.size'), 'Dot size (swarm plot)', min=0.1, max=5, value=1, step=0.1))
                            )
                        ),
                        fluidRow(
                            column(6, sliderInput(ns('Expression_subtype_XY_label.font.size'), 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                            column(6, sliderInput(ns('Expression_subtype_XY_title.font.size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                            column(6, sliderInput(ns('Expression_subtype_title.font.size'), 'Graph title font size', min=0.1, max=10, value=4, step=0.1))
                        ),
                        fluidRow(
                            column(6, materialSwitch(ns('Expression_subtype_white_background'), 'Use white background', value=FALSE, status = "success")),
                            column(6, materialSwitch(ns('Expression_subtype_rotate_x'), 'Rotate X axis label', value=FALSE, status = "success"))
                        ),
                        fluidRow(
                            column(6, selectInput(ns('Expression_subtype_select_colour_pallete'), 'Choose a colour palette',  c('None'='None', colour_pallets), selected = 'None'))
                        ),
                        fluidRow(
                            column(6, materialSwitch(ns('Expression_subtype_use_single_colour'), 'Use a single colour', value=FALSE, status = "success")),
                            column(6, htmlOutput(ns('Expression_subtype_choose_single_colour_ui')))
                        ),
                        circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                    )
                ),
                column(12, verbatimTextOutput(ns('Expression_subtype_error_catch'))), 
                column(12, withSpinner(plotOutput(ns("Expression_subtype_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
            )
        )
    )
    )   
}