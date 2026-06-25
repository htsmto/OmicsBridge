IntegrateTwoDataset_SideBySide_UI <- function(ns) {
    box(width=12, title='Side by Side comparison', collapsible=TRUE, status='primary', solidHeader = TRUE,
        # Direction
            box(width=12, title='Direction', collapsible=TRUE, status='info',
                fluidRow(
                    column(5, radioButtons(ns("Integrate_data_map_direction"), "", choices = c('See the selected genes from Data1 onto Data2'='A', 'See the selected genes from Data2 onto Data1'='B'), selected='A')),
                    column(5, h3('\n'), verbatimTextOutput(ns('Integrate_data_map_direction_note'))),
                    column(2, h3('\n'), actionButton(ns('reload_database'), 'Reload your datasets list', style="color: #ffffff; background-color: #1C9600; border-color: #2A8708"))
                )

            ),
        #

        # Data1. Slection and plot
            box(width=6, title='Data1', collapsible=TRUE, status='primary',

                ## data1 selection and setting
                # data selection and filtering button
                fluidRow(
                    # selection
                    column(8, htmlOutput(ns("Integrate_data1_select"))),

                    # dataset filtering button
                    column(2, 
                        fluidRow(
                            column(12, h5('')),
                            column(12, h5('')),
                            column(12, 
                                div(id='filterin_dropdown',
                                    dropdownButton( 
                                        fluidRow(
                                        column(12, h4(strong("Dataset filtering"))),
                                        column(12, htmlOutput(ns("Integrate_data1_Seuqenced_by"))), 
                                        column(12, htmlOutput(ns("Integrate_data1_Experiments"))), 
                                        column(12, htmlOutput(ns("Integrate_data1_Data_type")))   
                                        ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "400px",  tooltip = tooltipOptions(title = "Dataset filtering"), right=TRUE
                                    )
                                ) 
                            )
                        )
                    )
                ),

                # X/Y axis selection
                fluidRow( 
                    column(12, h5(strong('Please select x/y axis:')) ),  
                    column(6, htmlOutput(ns("Integrate_data1_Scat.X"))), 
                    column(6, htmlOutput(ns("Integrate_data1_Scat.Y")))
                ),

                # data1 plot
                fluidRow( 
                    column(10, verbatimTextOutput(ns('Integrate_data1_plot_status')) ),
                    column(2,
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6,sliderInput(ns('Integrate_data1_fig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput(ns('Integrate_data1_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(ns('Integrate_data1_pt.size'), 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                                column(6, sliderInput(ns('Integrate_data1_high.pt.size'), 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                                column(6, sliderInput(ns('Integrate_data1_high.label.size'), 'Highlighted labels size', min=0.1, max=5, value=1.5, step=0.1)),
                                column(6, sliderInput(ns('Integrate_data1_label.font.size'), 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                                column(6, sliderInput(ns('Integrate_data1_title.font.size'), 'X/Y title font size', min=1, max=15, value=4, step=0.1))
                            ),
                            fluidRow(
                                column(6, materialSwitch(ns('Integrate_data1_while_background'), 'Use white background', value=TRUE, status = "success")),
                                column(6, materialSwitch(ns('Integrate_data1_hide_labels'), 'Hide labels', value=TRUE, status='primary')),
                                column(6, colourpicker::colourInput(ns('Integrate_data1_colour_id'), 'highlighted dots colour:', value='red'))
                            ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                        )
                    ),
                    column(12, withSpinner(plotOutput(ns("Integrate_data1_plot"), brush = ns("Integrate_data1_plot_brush"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                    column(10,
                        conditionalPanel(condition = paste0("input['", ns("Integrate_data_map_direction"), "'] == 'A' "),
                            div(id='filterin_dropdown',
                                dropdownButton( h4(strong("Gene selection")),
                                    fluidRow(
                                        column(4, radioButtons(ns("Integrate_data1_Gene_selection"), "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),                      
                                        column(8,
                                            conditionalPanel(condition= paste0("input['", ns("Integrate_data1_Gene_selection"), "'] == 'A' "),    
                                                fluidRow(
                                                    column(6, 
                                                        fluidRow( 
                                                            column(12, numericInput(ns('Integrate_data1_thr_X1'), 'X1',  value=1, step=0.1) ), 
                                                            column(12, numericInput(ns('Integrate_data1_thr_X2'), 'X2',  value=-1, step=0.1) ) 
                                                        )
                                                    ),
                                                    column(6, 
                                                        fluidRow( 
                                                            column(12, numericInput(ns('Integrate_data1_thr_Y1'), 'Y1', value=1.3, step=0.1) ), 
                                                            column(12, numericInput(ns('Integrate_data1_thr_Y2'), 'Y2', value=0, step=0.1) ) 
                                                        )
                                                    ),
                                                    column(6, radioButtons(ns("Integrate_data1_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B')),
                                                    column(6, radioButtons(ns("Integrate_data1_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B')),
                                                    column(6, materialSwitch(ns('Integrate_data1_hide_threshold'), 'Hide threshold line', value=FALSE, status='primary')),
                                                )
                                            )
                                        )
                                    ),
                                    fluidRow(
                                        column(10, verbatimTextOutput(ns('Integrate_data1_selected_gene_num')))
                                    ),label='Gene selection', circle = FALSE, status = "primary", icon = icon("sliders"), width = "800px",  tooltip = tooltipOptions(title = "Gene selection")
                                )
                            ) 
                        )
                    )
                )
                ##
            ),
        #

        # Data2. Selection and plot
            box(width=6, title='Data2', collapsible=TRUE, status='primary',
                # selection and setting
                fluidRow(  # data selection and filtering button
                    column(8, htmlOutput(ns("Integrate_data2_select"))),
                    column(2, 
                        fluidRow(
                            column(12, h5('')),
                            column(12, h5('')),
                            column(12, 
                                div(id='filterin_dropdown',
                                    dropdownButton( 
                                        fluidRow(
                                            column(12, h4(strong("Dataset filtering"))),
                                            column(12, htmlOutput(ns("Integrate_data2_Seuqenced_by"))), 
                                            column(12, htmlOutput(ns("Integrate_data2_Experiments"))), 
                                            column(12, htmlOutput(ns("Integrate_data2_Data_type")))   
                                        ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "400px",  tooltip = tooltipOptions(title = "Dataset filtering"), right=TRUE
                                    )
                                ) 
                            )
                        )
                    )
                ),

                # X/Y axis selection
                fluidRow( 
                    column(12, h5(strong('Please select x/y axis:'))),
                    column(6, htmlOutput(ns("Integrate_data2_Scat.X"))), 
                    column(6, htmlOutput(ns("Integrate_data2_Scat.Y"))),
                ),

                # data2 plot
                fluidRow( 
                    column(10, verbatimTextOutput(ns('Integrate_data2_plot_status')) ),
                    column(2,
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6,sliderInput(ns('Integrate_data2_fig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput(ns('Integrate_data2_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(ns('Integrate_data2_pt.size'), 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                                column(6, sliderInput(ns('Integrate_data2_high.pt.size'), 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                                column(6, sliderInput(ns('Integrate_data2_high.label.size'), 'Highlighted labels size', min=0.1, max=5, value=1.5, step=0.1)),
                                column(6, sliderInput(ns('Integrate_data2_label.font.size'), 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                                column(6, sliderInput(ns('Integrate_data2_title.font.size'), 'X/Y title font size', min=1, max=15, value=4, step=0.1)),
                            ),
                            fluidRow(
                                column(6, materialSwitch(ns('Integrate_data2_while_background'), 'Use white background', value=TRUE, status = "success")),
                                column(6, materialSwitch(ns('Integrate_data2_hide_labels'), 'Hide labels', value=TRUE, status='primary')),
                                column(6, colourpicker::colourInput(ns('Integrate_data2_colour_id'), 'highlighted dots colour:', value='red'))
                            ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                        )
                    ),
                    column(12, withSpinner(plotOutput(ns("Integrate_data2_plot"), brush = ns("Integrate_data2_plot_brush"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                    column(10,
                        conditionalPanel(condition = paste0("input['", ns("Integrate_data_map_direction"), "'] == 'B' "),
                            div(id='filterin_dropdown',
                                dropdownButton( h4(strong("Gene selection")),
                                    fluidRow(
                                        column(4, radioButtons(ns("Integrate_data2_Gene_selection"), "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),
                                        column(8,
                                            conditionalPanel(condition= paste0("input['", ns("Integrate_data2_Gene_selection"), "'] == 'A' "),
                                                fluidRow(
                                                    column(6, fluidRow( column(12, numericInput(ns('Integrate_data2_thr_X1'), 'X1',  value=1, step=0.1) ), column(12, numericInput(ns('Integrate_data2_thr_X2'), 'X2',  value=-1, step=0.1) ) )),
                                                    column(6, fluidRow( column(12, numericInput(ns('Integrate_data2_thr_Y1'), 'Y1', value=1.3, step=0.1) ), column(12, numericInput(ns('Integrate_data2_thr_Y2'), 'Y2', value=0, step=0.1) ) )),
                                                    column(6, radioButtons(ns("Integrate_data2_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B')),
                                                    column(6, radioButtons(ns("Integrate_data2_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B')),
                                                    column(6, checkboxInput(ns("Integrate_data2_hide_threshold"), 'Hide threshold line', value=FALSE)),
                                                )
                                            )
                                        ),
                                        column(10, verbatimTextOutput(ns('Integrate_data2_selected_gene_num')))
                                    ),label='Gene selection', circle = FALSE, status = "primary", icon = icon("sliders"), width = "800px",  tooltip = tooltipOptions(title = "Gene selection")
                                )
                            )   
                        )
                    )
                )
                #
            ),
        #

    ## display overlap genes
        box(width=12, title='Overlap genes', collapsible=TRUE, status='warning', 
            # filtering for the mapped side
            fluidRow(
                column(12, 
                    helpText(HTML('A list of genes that meet the filter settings in both datasets is displayed here.
                        <br>Please set the threshoolds for the data to which the selected genes are mapped.'))
                ),
                column(12, 
                    div(id='filterin_dropdown',
                        dropdownButton( 
                            fluidRow( 
                                column(12, h4(strong('Set the filtering for the mapped side'))),
                                column(3, fluidRow( column(12, numericInput(ns('Integrate_data_mapped_thr_X1'), 'X1',  value=1, step=0.1) ), column(12, numericInput(ns('Integrate_data_mapped_thr_X2'), 'X2',  value=-1, step=0.1) ) ) ), 
                                column(3, fluidRow( column(12, numericInput(ns('Integrate_data_mapped_thr_Y1'), 'Y1',  value=1, step=0.1) ), column(12, numericInput(ns('Integrate_data_mapped_thr_Y2'), 'Y2',  value=-1, step=0.1) ) )  ),
                                column(3, radioButtons(ns("Integrate_data_mapped_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='A')),
                                column(3, radioButtons(ns("Integrate_data_mapped_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='A')),
                                column(6, materialSwitch(ns('Integrate_data_mapped_hide_threshold'), 'Hide threshold line', value=FALSE, status='primary'))
                            ),label='The filtering for the mapped side', circle = FALSE, status = "primary", icon = icon("sliders"), width = "900px",  tooltip = tooltipOptions(title = "Dataset filtering")
                        )
                    ) 
                )
            ),

            # show a table of the overlap genes
            fluidRow(
                column(12, h5('\n')),
                column(12, h4('Overlap genes table') ),
                column(12, verbatimTextOutput(ns('Integrate_Overlapped_gene_table_status')) ),
                column(12, dataTableOutput(ns("Integrate_Overlapped_gene_table")) ),
            ),
            
            fluidRow(
                # download button
                column(3, downloadButton(ns('Integrate_Overlapped_gene_table_download'),"Download this table")),

                # show the list of the overlap genes
                column(5, 
                    box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', 
                        verbatimTextOutput(ns('Integrate_Overlapped_gene_list')) 
                    )
                )
            )
        )
    
    )
}