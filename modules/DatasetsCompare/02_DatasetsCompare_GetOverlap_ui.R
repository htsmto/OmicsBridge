DatasetsCompare_GetOverlap_UI <- function(ns){
    fluidRow(
        column(12, # Settings and Inputs
            box(width=12, title=strong('Settings and Inputs'), collapsible = TRUE, status='info',
                fluidRow( 
                    column(12, helpText(HTML("Please select the score for ranking (ex. LFC), choose the direction (either top or bottom), set the threshold, and click 'Investigate the Overlap'. <br>A table displaying how often each gene ranks in the top or bottom X% of the selected datasets will appear below."))) ,

                    # status
                    column(6, verbatimTextOutput(ns('Compare_dataset_get_overview_status_input'))),
                
                ),
                fluidRow(

                    # select score for ranking
                    column(3, htmlOutput(ns('Compare_dataset_get_overview_select_score'))),

                    # select direction (top or bottom)
                    column(2, radioButtons(ns('Compare_dataset_get_overview_direction'), 'Direction:', choices=c('Top X%', 'Bottom X%'))),

                    # set threshold
                    column(5, 
                        fluidRow(
                            column(12, sliderInput(ns('Compare_dataset_get_overview_threshold'), 'Threshold X(%)=', min=0, max=100, value=5, step=1)),
                            column(7, numericInput(ns('Compare_dataset_get_overview_threshold_for_display'), 'Show genes with Overlap_time more than:', value=0, min=0, max=1000, step=1)),
                            column(5, ''),
                            column(12, helpText(HTML("ex. if you set Top 5% and show genes with Overlap_time more than 2, it means that you want to see the genes that are ranked in the top 5% in at least 2 datasets.")))
                        )
                    ),
                ),
                fluidRow(

                    # start comparing
                    column(3, actionButton(ns('Compare_dataset_get_overview_start'), 'Investigate the overlap',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                    column(6, verbatimTextOutput(ns('Compare_dataset_get_overview_status'))),
                )
            ),                      
        ),
        column(4, # Overlapped hits
            box(width=12, title=strong('Overlapped hits'), collapsible = TRUE, status='warning',
                fluidRow( 
                    column(12, verbatimTextOutput(ns('Compare_dataset_get_overview_table_status'))),
                    column(12, withSpinner(dataTableOutput(ns("Compare_dataset_get_overview_overlap")), type=5, color='#0dc5c1') ),
                    column(12, h2('')),
                    column(12, 
                        fluidRow(
                            column(5, downloadButton(ns('Compare_dataset_get_overview_download'),"Download this table", style="color: #ffffff; background-color: #ee9d29; border-color: #e48803")),
                            column(7, 
                                box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput(ns('Compare_dataset_get_overview_list')),
                                    fluidRow(
                                        column(12, helpText(HTML("The list of the genes in the table above."))),
                                        column(12, htmlOutput(ns('Compare_dataset_get_overview_list_genes_select'))),
                                        column(12, verbatimTextOutput(ns('Compare_dataset_get_overview_list_genes_select_status')))
                                    )
                                )
                            )
                        )
                    )
                )
            ),
        ),
        column(8, # barplot
            box(width=12, title=strong('barplot'), collapsible = TRUE,status='danger',
                fluidRow(
                    column(10, verbatimTextOutput(ns('Compare_dataset_get_overview_barplot_status'))),
                    column(2,
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6,sliderInput(ns('Compare_dataset_get_overview_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                column(6,sliderInput(ns('Compare_dataset_get_overview_fig.height'), 'Fig height', min=300, max=3000, value=800, step=10)),
                            ),
                            fluidRow(
                                column(6, sliderInput(ns('Compare_dataset_get_overview_label.font.size'), 'X/Y label font size', min=1, max=10, value=4, step=0.1)),
                                column(6, sliderInput(ns('Compare_dataset_get_overview_title.font.size'), 'X/Y title font size', min=1, max=10, value=4, step=0.1)),
                                column(6, sliderInput(ns('Compare_dataset_get_overview_graph.title.font.size'), 'Graph title font size', min=1, max=10, value=4, step=0.1)),
                                column(6, sliderInput(ns('Compare_dataset_get_overview_legend_size'), 'Legend font size', min=1, max=10, value=4, step=0.1))
                            ),
                            fluidRow(
                                column(4, colourpicker::colourInput(ns('Compare_dataset_get_overview_highest_colour'), 'Colour for the highest value', value='red')),
                                column(4, colourpicker::colourInput(ns('Compare_dataset_get_overview_lowest_colour'), 'Colour for the lowest value', value='blue')),
                                column(4, colourpicker::colourInput(ns('Compare_dataset_get_overview_zero_colour'), 'Colour for zero', value='white')),
                                column(12, materialSwitch(ns('Compare_dataset_get_overview_white_background'), 'Use white background', value=FALSE, status = "success")),
                                column(12,
                                    fluidRow(
                                        column(6, materialSwitch(ns('Compare_dataset_get_overview_manual_colour_range'), 'Use manual colour range', value=FALSE, status = "success")),
                                        conditionalPanel(condition = paste0("input['", ns('Compare_dataset_get_overview_manual_colour_range'), "'] == true"),
                                            column(3, numericInput(ns('Compare_dataset_get_overview_manual_colour_range_high'), 'High value', value=1, step=0.1)),
                                            column(3, numericInput(ns('Compare_dataset_get_overview_manual_colour_range_low'), 'Low value', value=-1, step=0.1))
                                        )
                                    )
                                ),
                                column(12,
                                    fluidRow(
                                        column(6, materialSwitch(ns('Compare_dataset_get_overview_manual_y_axis_range'), 'Use manual y-axis range', value=FALSE, status = "success")),
                                        conditionalPanel(condition = paste0("input['", ns('Compare_dataset_get_overview_manual_y_axis_range'), "'] == true"),
                                            column(3, numericInput(ns('Compare_dataset_get_overview_manual_y_axis_range_high'), 'High value', value=1, step=0.1)),
                                            column(3, numericInput(ns('Compare_dataset_get_overview_manual_y_axis_range_low'), 'Low value', value=-1, step=0.1))
                                        )                                        
                                    )
                                )

                            ),
                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                    ),
                    column(12, withSpinner(plotOutput(ns("Compare_dataset_get_overview_barplot"), width="100%", height="100%"),  type=5, color='#0dc5c1') )
                )
            )                      
        )
    )
}