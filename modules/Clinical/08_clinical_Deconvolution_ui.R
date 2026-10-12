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
                ),
                tabPanel("Association with mutations",
                    fluidRow(

                        # Inputs and Settings / Test results
                        column(4,
                            box(width=12, title='Inputs and Settings', status='info', collapsible=TRUE,
                                fluidRow(
                                    column(12, helpText("Here, you can compare the abundance of a specific cell type between the samples with and without mutations (WT) in each gene. Samples without a reported mutation in the gene are treated as WT.")),
                                    column(12, htmlOutput(ns('Deconvolution_Mutation_genes'))),
                                    column(12, materialSwitch(ns('Deconvolution_Mutation_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                                    column(12, htmlOutput(ns('Deconvolution_Mutation_from_custom_geneset_select'))),
                                    column(12, verbatimTextOutput(ns('Deconvolution_Mutation_genes_status'))),
                                    column(12, htmlOutput(ns('Deconvolution_Mutation_select_celltype')) ),
                                    column(12, actionButton(ns('Deconvolution_Mutation_start'), 'Start comparing',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) ),
                                    column(12, h4('') ),
                                    column(12, verbatimTextOutput(ns('Deconvolution_Mutation_status0')) )
                                )
                            ),
                            box(width=12, title='Test Results', status='warning', collapsible=TRUE,
                                fluidRow(
                                    column(12, verbatimTextOutput(ns('Deconvolution_Mutation_table_note')) ),
                                    column(12, verbatimTextOutput(ns('Deconvolution_Mutation_table_status')) ),
                                    column(12, withSpinner(dataTableOutput(ns("Deconvolution_Mutation_table")), type = 5, color = "#0dc5c1" )),
                                    column(12, downloadButton(ns('Deconvolution_Mutation_table_download'),"Download this table") )
                                )
                            )
                        ),

                        # Plot
                        column(8,
                            box(width=12, title='Plot', status='danger', collapsible=TRUE,
                                fluidRow(
                                    column(10, verbatimTextOutput(ns('Deconvolution_Mutation_plot_status')) ),
                                    column(2,
                                        dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                                column(6, sliderInput(ns('Deconvolution_Mutation_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                                                column(6, sliderInput(ns('Deconvolution_Mutation_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                                                conditionalPanel(
                                                    condition = paste0("input['", ns('Deconvolution_Mutation_figtype'), "'] == 'C' || input['", ns('Deconvolution_Mutation_figtype'), "'] == 'D' || input['", ns('Deconvolution_Mutation_split_by_type'), "'] == true"),
                                                    column(6, sliderInput(ns('Deconvolution_Mutation_dot.size'), 'Dot size (swarm plot)', min=0.01, max=3, value=0.3, step=0.01))
                                                )
                                            ),
                                            fluidRow(
                                                column(6, sliderInput(ns('Deconvolution_Mutation_XY_label.font.size'), 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Mutation_XY_title.font.size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                                column(6, sliderInput(ns('Deconvolution_Mutation_title.font.size'), 'Graph title font size', min=0.1, max=10, value=4, step=0.1))
                                            ),
                                            fluidRow(
                                                column(6, colourpicker::colourInput(ns('Deconvolution_Mutation_col_mut'), 'Colour (mutation)', value='#cd0202')),
                                                column(6, colourpicker::colourInput(ns('Deconvolution_Mutation_col_wt'), 'Colour (wild type)', value='#3f48ee')),
                                                column(6, selectInput(ns('Deconvolution_Mutation_select_colour_pallete'), 'Colour palette for mutation types', c('None'='None', colour_pallets), selected = 'None'))
                                            ),
                                            fluidRow(
                                                column(6, materialSwitch(ns('Deconvolution_Mutation_white_background'), 'Use white background', value=FALSE, status = "success")),
                                                column(6, materialSwitch(ns('Deconvolution_Mutation_rotate_x'), 'Rotate X axis label', value=FALSE, status = "success"))
                                            ),
                                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                        )
                                    ),
                                    # the mutation-type view is always a swarm plot, so hide the plot type options when the switch is on
                                    conditionalPanel(
                                        condition = paste0("input['", ns('Deconvolution_Mutation_split_by_type'), "'] != true"),
                                        column(12, radioButtons(ns('Deconvolution_Mutation_figtype'), 'Plot type', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A', inline=TRUE) )
                                    ),
                                    column(12, materialSwitch(ns('Deconvolution_Mutation_split_by_type'), 'Split the mutant group by the type of mutation', value=FALSE, status='info') ),
                                    conditionalPanel(
                                        condition = paste0("input['", ns('Deconvolution_Mutation_split_by_type'), "'] == true"),
                                        column(4, numericInput(ns('Deconvolution_Mutation_top_types'), 'Show top X mutation types (the rest are grouped as "Others")', min=1, value=10, step=1))
                                    ),
                                    column(12, withSpinner(plotOutput(ns("Deconvolution_Mutation_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                )
                            )
                        )
                    )
                )
            )
        )  
    )
  
}