clinical_Deconvolution_ui <- function(ns){
    tagList(
        # Do deconvolution
        box(width=12, title=strong('Deconvolution'),collapsible=TRUE, status='primary',
            fluidRow(
                column(2,
                fluidRow(
                    column(12, radioButtons(ns('Deconvolution_tool_select'), "Choose a method:", choices=c('MCPcounter', 'xCell'), selected='MCPcounter') ),
                    column(12, h4('')),
                    column(12, actionButton(ns('Deconvolution_start'), "Start deconvolution", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) )
                )
                ),
                column(10,
                fluidRow(
                    column(12, h4('Deconvolution Results Table') ),
                    column(12, h3('')),
                    column(12, verbatimTextOutput(ns('Deconvolution_status')) ),
                    column(12, withSpinner(dataTableOutput(ns("Deconvolution_results")), type = 5, color = "#0dc5c1" )),
                    column(12, downloadButton(ns('Deconvolution_result_download'),"Download this table") )
                )
                )
            )
        ),

        # further analysis
        box(width=12, title=strong('Further Analysis'), status='primary',
            tabsetPanel(
                tabPanel("Heatmap/Barplot",
                    fluidRow(

                        # Inputs and Settings
                        column(4,
                            box(title='Inputs and Settings', width=12, status='info', collapsible=TRUE,
                                fluidRow(
                                    column(12, helpText("Here, you can generate heatmaps or barplots of the deconvolution results (abundance of each cell type across samples).")),
                                    column(12, radioButtons(ns('Deconvolution_Heatmap_sample_selection'), 'Sample selection', choices=c('All samples'='A', 'Filter from metadata'='B', 'Text input'='C'), selected='A') ),
                                    column(12, htmlOutput(ns('Deconvolution_Heatmap_sample_selection_meta_data')) ),
                                    column(12, htmlOutput(ns('Deconvolution_Heatmap_sample_selection_meta_data_group')) ),
                                    column(12, htmlOutput(ns('Deconvolution_Heatmap_sample_selection_text_input')) ),
                                    column(12, verbatimTextOutput(ns('Deconvolution_Heatmap_sample_selection_meta_data_status')) )
                                ),
                                fluidRow(
                                    column(12, h4('') ),
                                    column(12, radioButtons(ns('Deconvolution_Heatmap_celltype_selection'), 'Cell type selection', choices=c('All cell types'='A', 'Select cell types'='B'), selected='A') ),
                                    column(12,  dataTableOutput(ns('Deconvolution_Heatmap_celltype_selection_table')))
                                ),
                                fluidRow(
                                    column(12, h4('') ),
                                    column(12, actionButton(ns('Deconvolution_Heatmap_start'), 'Show a heatmap',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) )
                                )
                            )
                        ),

                        # Plots
                        column(8,
                            box(title='Plot', width=12, status='danger', collapsible=TRUE,
                                verbatimTextOutput(ns('Deconvolution_plot_status')) ,
                                tabsetPanel(
                                    # Heatmap
                                    tabPanel('Heatmap',
                                        fluidRow(
                                        column(12, h4('')),
                                        column(10, verbatimTextOutput(ns('Deconvolution_Heatmap_status')) ),
                                        column(2, 
                                            dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                                column(6,sliderInput(ns('Deconvolution_Heatmap_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                                column(6,sliderInput(ns('Deconvolution_Heatmap_fig.height'), 'Fig height', min=300, max=3000, value=800, step=10)),
                                            ),
                                            fluidRow(
                                                column(6, sliderInput(ns('Deconvolution_Heatmap_X_font.size'), 'X-axis font size', min=0, max=10, value=3, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Heatmap_Y_font.size'), 'Y-axis font size', min=0, max=10, value=2, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Heatmap_legend_font.size'), 'Legend font size', min=1, max=10, value=3, step=0.1))
                                            ),
                                            fluidRow(
                                                column(6, colourpicker::colourInput(ns('Deconvolution_Heatmap_high_colour'), 'Colour of the highest value:', value='red')),
                                                column(6, colourpicker::colourInput(ns('Deconvolution_Heatmap_zero_colour'), 'Colour of 0:', value='white')),
                                            ),
                                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                            ) 
                                        ),
                                        column(12, withSpinner(plotOutput(ns("Deconvolution_Heatmap_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                        ),
                                    ),

                                    # Barplot
                                    tabPanel('Barplot',
                                        fluidRow(
                                        column(12, h4('')),
                                        column(10, verbatimTextOutput(ns('Deconvolution_Barplot_status')) ),
                                        column(2, 
                                            dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                                column(6,sliderInput(ns('Deconvolution_Barplot_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                                column(6,sliderInput(ns('Deconvolution_Barplot_fig.height'), 'Fig height', min=300, max=3000, value=800, step=10)),
                                            ),
                                            fluidRow(
                                                column(6, sliderInput(ns('Deconvolution_Barplot_X_font.size'), 'X-axis font size', min=0, max=10, value=3, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Barplot_Y_font.size'), 'Y-axis font size', min=0, max=10, value=2, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Barplot_legend_font.size'), 'Legend font size', min=1, max=10, value=3, step=0.1))
                                            ),
                                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                            ) 
                                        ),
                                        column(12, materialSwitch(ns('Deconvolution_Barplot_percentage'), 'Percentile plot', value=FALSE, status = "success")),
                                        column(12, withSpinner(plotOutput(ns("Deconvolution_Barplot_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                        )
                                    )
                                )

                            )
                        )
                    )
                ),
                tabPanel("Correlation with genes",
                    fluidRow(

                        # Inputs and Setttings
                        column(12, 
                            box(width=12, title='Inputs and Settings', status='info',collapsible=TRUE,
                                fluidRow(
                                    helpText("Here, you can correlate the abundance of a specific cell type with the expression of a specific gene across samples."),
                                    # Inputs
                                    column(4, 
                                        fluidRow(
                                            column(12, htmlOutput(ns('Deconvolution_Gene_correlation_genes'))),
                                            column(12, materialSwitch(ns('Deconvolution_Gene_correlation_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                                            column(12, htmlOutput(ns('Deconvolution_Gene_correlation_from_custom_geneset_select'))),
                                            column(12, verbatimTextOutput(ns('Deconvolution_Gene_correlation_genes_status')))
                                        )
                                    ),

                                    # select a cell type
                                    column(3,
                                        fluidRow(
                                            column(12, htmlOutput(ns('Deconvolution_Gene_correlation_select_celltype')) )
                                        )
                                    ),

                                    # sample filtering
                                    column(3,
                                        fluidRow(
                                            column(12, radioButtons(ns('Deconvolution_filter'), 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                                            column(12, htmlOutput(ns('Deconvolution_filter_selection'))),
                                            column(12, htmlOutput(ns('Deconvolution_filter_selection_category'))),
                                            column(12, verbatimTextOutput(ns('Deconvolution_filter_selection_number')))
                                        )
                                    ),

                                    # correlation method and start button
                                    column(2,
                                        fluidRow(
                                            column(12, radioButtons(ns('Deconvolution_Gene_correlation_method'), 'Method for correlation', choices=c('pearson', 'spearman'), selected='pearson')  ),
                                            column(12, h4('') ),
                                            column(12, actionButton(ns('Deconvolution_Gene_correlation_start'), 'Calculate the correlation',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) )
                                        )
                                    ),
                                ),

                                # status
                                fluidRow(
                                    column(8, verbatimTextOutput(ns('Deconvolution_Gene_correlation_status0')) )
                                )
                            )                              
                        ),

                        # table show
                        column(4, 
                            box(width=12, title='Correlation table', status='warning',collapsible=TRUE,
                                fluidRow(
                                    column(12, verbatimTextOutput(ns('Deconvolution_Gene_correlation_status1')) ),
                                    column(12, dataTableOutput(ns("Deconvolution_Gene_correlation_table")) ),
                                    column(12, downloadButton(ns('Deconvolution_Gene_correlation_table_download'),"Download this table") )
                                )
                            )
                        ),

                        # Plot
                        column(8,
                            box(width=12, title='Plot', status='danger', collapsible=TRUE,
                                fluidRow(
                                    column(10, verbatimTextOutput(ns('Deconvolution_Gene_correlation_status')) ),
                                    column(2,
                                        dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6,sliderInput(ns('Deconvolution_Gene_correlation_fig.width'), 'Fig width', min=300, max=3000, value=700, step=10)),
                                            column(6,sliderInput(ns('Deconvolution_Gene_correlation_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10)),
                                        ),
                                        fluidRow(
                                            column(6,sliderInput(ns('Deconvolution_Gene_correlation_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6,sliderInput(ns('Deconvolution_Gene_correlation_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        ),
                                        fluidRow(
                                            column(6, colourpicker::colourInput(ns('Deconvolution_Gene_correlation_colour'), 'Colour of the dots:', value='#ec00ec')),
                                            column(6, materialSwitch(ns('Deconvolution_Gene_correlation_show_correlation_line'), 'Show the correlation line', value=TRUE, status='success')),
                                            column(6, materialSwitch(ns('Deconvolution_Gene_correlation_white_background'), 'Use white background', value=FALSE, status = "success"))
                                        ),circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                        )
                                    ),
                                    column(12, withSpinner(plotOutput(ns("Deconvolution_Gene_correlation_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                )
                            )
                        )
                    )
                )
            )
        )  
    )
  
}