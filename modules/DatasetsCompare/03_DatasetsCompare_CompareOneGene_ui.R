DatasetsCompare_CompareOneGene_UI <- function(ns){
    fluidRow(
        column(12, # Settings and Inputs
            box(width=12, collapsible=TRUE, title=strong('Inputs and Settings'), status='info',
                fluidRow( 
                    column(12, helpText(HTML("Please enter genes here and choose which score you use for the y-axis and the colour of the plot. <br>A bar or scatter plot comparing the score (selected as Y-axis) of each gene across the selected datasets will be generated in the end."))),
                    column(6, verbatimTextOutput(ns('Compare_dataset_comparing_one_gene_status_input'))),
                ),
                fluidRow(
                    column(5, 
                        fluidRow(
                            column(12, htmlOutput(ns("target_gene_for_comparing"))),
                            column(12, materialSwitch(ns('target_gene_for_comparing_Input_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                            conditionalPanel(condition = paste0("input['", ns('target_gene_for_comparing_Input_from_custom_geneset'), "'] == true"),
                                column(12, htmlOutput(ns('target_gene_for_comparing_Input_from_custom_geneset_select')))
                            )
                        )
                    ),
                    column(4, 
                        fluidRow(
                            column(12,htmlOutput(ns("Choose_datasets_y"))),
                            column(12,htmlOutput(ns("Choose_datasets_colour")))
                        )
                    ),
                    column(3, 
                        actionButton(ns("comparison_start"), "Start Comparison Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")
                    )
                )
            )
        ),

        # Input gene list
        column(4,
            box(width=12, collapsible=TRUE, title=strong('Input Genes'), status='primary',
                fluidRow(
                    column(12, h5('Select a gene below:')),
                    column(12, verbatimTextOutput(ns('Gene_comparing_selected_gene_status'))),
                    column(12, withSpinner(dataTableOutput(ns("Gene_comparing_gene_list_table")), type = 5, color='#0dc5c1') )
                )
            ),
            box(width=12, collapsible=TRUE, title=strong('Data Information'),  status='warning',
                fluidRow(
                    column(12, verbatimTextOutput(ns('dataframe_comparing_dataset_status'))),
                    column(12, withSpinner(dataTableOutput(ns("dataframe_comparing_dataset")), type=5, color='#0dc5c1') ),
                    column(12, downloadButton(ns('comparing_dataset_download'),"Download this table"))
                )
            ),
        ),
        column(8,
            box(width=12, collapsible=TRUE, title=strong('Plot'), status='danger',
                fluidRow(
                    column(10, radioButtons(ns("bar_or_scatter"), "Plot type", choices = c( "Scatter plot", "Bar plot"), selected='Bar plot', inline=TRUE)),
                    column(2,
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6, sliderInput(ns('Compare_fig.width'), 'Fig width', min=300, max=3000, value=850, step=10)),
                                column(6, sliderInput(ns('Compare_fig.height'), 'Fig height', min=300, max=3000, value=800, step=10)),
                                conditionalPanel(
                                    condition = paste0("input['", ns("bar_or_scatter"), "'] == 'Scatter plot'"),
                                    column(6, sliderInput(ns('Compare_pt.size'), 'Point size', min=0.1, max=10, value=3, step=0.1))
                                )
                            ),
                            fluidRow(
                                column(6, sliderInput(ns('Compare_label.font.size'), 'X/Y label font size', min=1, max=10, value=4, step=1)),
                                column(6, sliderInput(ns('Compare_title.font.size'), 'X/Y title font size', min=1, max=10, value=4, step=1)),
                                column(6, sliderInput(ns('Compare_graph.title.font.size'), 'Graph title font size', min=1, max=15, value=4, step=1)),
                                column(6, sliderInput(ns('Compare_label_legend_size'), 'Legend font size', min=1, max=15, value=4, step=1)),
                            ),
                            fluidRow(
                                column(4, colourpicker::colourInput(ns('Compare_highest_colour'), 'Colour for the highest value', value='red')),
                                column(4, colourpicker::colourInput(ns('Compare_lowest_colour'), 'Colour for the lowest value', value='blue')),
                                column(4, colourpicker::colourInput(ns('Compare_zero_colour'), 'Colour for the zero value', value='white')),
                            ),
                            fluidRow(
                                column(12, materialSwitch(ns('Compare_white_background'), 'Use white background', value=FALSE, status = "success"))
                            ),
                            fluidRow(
                                column(6, materialSwitch(ns('Compare_manual_colour_range'), 'Use manual colour range', value=FALSE, status = "success")),
                                conditionalPanel(condition = paste0("input['", ns('Compare_manual_colour_range'), "'] == true"),
                                    column(3, numericInput(ns('Compare_manual_colour_range_high'), 'High value', value=1, step=0.1)),
                                    column(3, numericInput(ns('Compare_manual_colour_range_low'), 'Low value', value=-1, step=0.1))
                                )
                            ),
                            fluidRow(
                                column(6, materialSwitch(ns('Compare_manual_y_axis_range'), 'Use manual y-axis range', value=FALSE, status = "success")),
                                conditionalPanel( condition = paste0("input['", ns('Compare_manual_y_axis_range'), "'] == true"),
                                    column(3, numericInput(ns('Compare_manual_y_axis_range_high'), 'High value', value=1, step=0.1)),
                                    column(3, numericInput(ns('Compare_manual_y_axis_range_low'), 'Low value', value=-1, step=0.1))
                                )
                            ),
                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                    ),
                    column(12, verbatimTextOutput(ns('Gene_comparing_plot_status')) ),
                    column(12, withSpinner(plotOutput(ns("Gene_comparing_plot"), width="100%", height="100%"), type=5, color='#0dc5c1'))
                )
            )
        )
    )   
}