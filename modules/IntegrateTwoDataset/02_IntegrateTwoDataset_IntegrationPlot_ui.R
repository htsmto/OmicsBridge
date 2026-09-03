IntegrateTwoDataset_IntegrationPlot_UI <- function(ns) {
    box(width=12, title='Integration Plot', collapsible=TRUE, status='primary', solidHeader = TRUE,
        fluidRow(
            # Plot
            column(6, 
                box(width=12, title='Plot', status='danger', 

                    # axis and colour
                    fluidRow( 
                        column(6, htmlOutput(ns("Integrate_data1_plus_2_Scat.X"))), 
                        column(6, htmlOutput(ns("Integrate_data1_plus_2_Scat.Y"))),
                        column(6, htmlOutput(ns("Integrate_data1_plus_2_Scat.colour")))
                    ),

                    # plot
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Integrate_data1_plus_2_plot_status'))),
                        column(2,
                            dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6,sliderInput(ns('Integrate_data1_plus_2_fig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_XY_label_size'), 'X/Y label size', min=1, max=10, value=5, step=0.1)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_XY_title_size'), 'X/Y title size', min=1, max=10, value=5, step=0.1)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_dot_label_size'), 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_highlight_dot_size'), 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                                column(6,sliderInput(ns('Integrate_data1_plus_2_id_size'), 'Label size', min=0.1, max=5, value=1, step=0.1)),
                            ),
                            fluidRow(
                                column(6, materialSwitch(ns('Integrate_data1_plus_2_white_background'), 'Use white background', value=FALSE, status='success'))
                            ),
                            circle = FALSE, status = "success", icon = icon("gear"), width = "600px",   tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(12, withSpinner(plotOutput(ns("Integrate_data1_plus_2_plot"), brush = ns("Integrate_data1_plus_2_plot_brush"), width="100%", height="100%"), type=5, color='#0dc5c1')),
                        column(4, materialSwitch(ns('Integrate_data1_plus_2_draw_y_x'), 'Draw y=x line', value=FALSE, status='primary')),
                        column(4, materialSwitch(ns('Integrate_data1_plus_2_draw_y_minusx'), 'Draw y=-x line', value=FALSE, status='primary')),
                    )
                )
            ),

            # Display options
            column(6,  
                box(width=12, title='Highlight Genes', collapsible=TRUE,status='info',

                    # Input sepecifc genes
                    fluidRow(
                        column(12, h4(HTML('<u>Highlight specific genes</u>'))),
                        column(12, helpText('Enter gene names (one per line) to highlight them on the plot.')),
                        column(9,
                            fluidRow(
                                column(12, htmlOutput(ns("Integrate_data1_plus_2_target_gene")))
                            )
                        )
                    ),
                    fluidRow(
                        column(4, materialSwitch(ns('Integrate_data1_plus_2_show_gene_name'), 'Show gene names', value=TRUE, status='info')),
                        column(12,
                            fluidRow(
                                column(6, materialSwitch(ns('Integrate_data1_plus_2_change_colour'), 'Change colour of the selected genes', value=FALSE, status='info')),
                                conditionalPanel(condition = paste0("input['", ns('Integrate_data1_plus_2_change_colour'), "'] == true"),
                                    column(6, colourpicker::colourInput(ns('Integrate_data1_plus_2_target_gene_colour'), 'Colour of the selected genes:', value='red'))
                                )
                            )
                        )
                    ),

                    # Filtering
                    fluidRow(
                        column(12, h4(HTML('<u>Filtering</u>'))),
                        column(12, helpText('You can filter and highlight the genes by setting thresholds on X and Y axes. The filtered genes will be shown in a table below the plot.')),
                        column(12, materialSwitch(ns('Integrate_data1_plus_2_plot_use_geneset'), 'Use pathway genes or custom gene sets', value=FALSE, status='info')),
                        column(12,
                            conditionalPanel(condition = paste0("input['", ns('Integrate_data1_plus_2_plot_use_geneset'), "'] == true"),
                                fluidRow(
                                    column(4, radioButtons(ns("Integrate_data1_plus_2_plot_pathway_dataset_select"), "pathways from:",
                                        choices = c("HALLMARK (human)", "HALLMARK (mouse)", "Custom (GMT file)", "Custom gene sets"))),
                                    column(8,
                                        fluidRow(
                                            column(12,
                                                conditionalPanel(condition = paste0("input['", ns('Integrate_data1_plus_2_plot_pathway_dataset_select'), "'] == 'Custom (GMT file)'"),
                                                    fileInput(ns("Integrate_data1_plus_2_plot_upload_custom_pathway_file"), "Upload a gmt file")
                                                )
                                            ),
                                            column(12,
                                                conditionalPanel(condition = paste0("input['", ns('Integrate_data1_plus_2_plot_pathway_dataset_select'), "'] == 'Custom gene sets'"),
                                                    htmlOutput(ns("Integrate_data1_plus_2_plot_custom_geneset_select"))
                                                )
                                            ),
                                            column(12,
                                                conditionalPanel(condition = paste0("input['", ns('Integrate_data1_plus_2_plot_pathway_dataset_select'), "'] != 'Custom gene sets'"),
                                                    htmlOutput(ns("Integrate_data1_plus_2_plot_select_pathway"))
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        ),

                        # X and Y axis threshold for filtering
                        column(12,
                            fluidRow(
                                column(4, radioButtons(ns('Integrate_data1_plus_2_plot_xselect'), 'Select how to filter X', choices=c("None"= "E", "X > X1" = "A", "X < X2"= "B", "X2 < X < X1"="C", "X < X2 or X > X1"="D"), selected="E")),
                                column(4, radioButtons(ns('Integrate_data1_plus_2_plot_yselect'), 'Select how to filter Y', choices=c("None"= "E", "Y > Y1" = "A", "Y < Y2"="B", "Y2 < Y < Y1"="C", "Y < Y2 or Y > Y1"="D"), selected="E")),
                                column(4,
                                    fluidRow(
                                        column(6, numericInput(ns('Integrate_data1_plus_2_plot_xthr1'), 'X1', value=1, step=0.1 ) ),
                                        column(6, numericInput(ns('Integrate_data1_plus_2_plot_xthr2'), 'X2', value=-1, step=0.1 ) ),
                                        column(6, numericInput(ns('Integrate_data1_plus_2_plot_ythr1'), 'Y1', value=1, step=0.1 ) ),
                                        column(6, numericInput(ns('Integrate_data1_plus_2_plot_ythr2'), 'Y2', value=-1, step=0.1 ) )
                                    )
                                )
                            )
                        ),
                        column(12, verbatimTextOutput(ns('Integrate_data1_plus_2_filter_summary'))),
                        column(12,
                            fluidRow(
                                column(12, materialSwitch(ns('Integrate_data1_plus_2_plot_filter_label'), 'Hide labels', value=FALSE, status='info')),
                                column(12, 
                                    fluidRow(
                                        column(6, materialSwitch(ns('Integrate_data1_plus_2_plot_filter_change_colour'), 'Change colour', value=FALSE, status='info')),
                                        conditionalPanel(
                                            condition = paste0("input['", ns('Integrate_data1_plus_2_plot_filter_change_colour'), "'] == true"),
                                            column(6, colourpicker::colourInput(ns('Integrate_data1_plus_2_plot_filter_colour'), 'Colour of the filtered genes:', value='blue'))
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            ),

            # Filtered area
            column(12, 
                box(width=12, title='Filtered Area', collapsible=TRUE, collapsed=TRUE,status='warning',
                    fluidRow(column(12, verbatimTextOutput(ns('Integrate_data1_plus_2_filtered_status')))),
                    fluidRow(column(12, dataTableOutput(ns("Integrate_data1_plus_2_filtered")))),
                    fluidRow(column(12, h4(''))),
                    fluidRow(
                    column(4, downloadButton(ns('Integrate_data1_plus_2_filtered_download'),"Download this table")),
                    column(4, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput(ns('Integrate_data1_plus_2_filtered_gene_list')) ))
                    )
                )
            ),

            #Selected area
            column(12, 
                box(width=12, title='Selected Area', collapsible=TRUE,status='warning',
                    fluidRow(column(12, dataTableOutput(ns("Integrate_data1_plus_2_selected")))),
                    fluidRow(
                    column(4, downloadButton(ns('Integrate_data1_plus_2_selected_download'),"Download this table")),
                    column(4, 
                        box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput(ns('Integrate_data1_plus_2_selected_gene_list')) )
                    )
                    )
                )
            )
        )
    )
}