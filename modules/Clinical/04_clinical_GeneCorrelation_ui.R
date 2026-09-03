clinical_GeneCorrelation_ui <- function(ns){
    tagList(
        fluidRow(
            column(12, 

                # Input and Settings
                box(width=12, status='info', title='Inputs and Settings',
                    fluidPage(
                        column(12, helpText(HTML("Here, you can explore the correlation of gene expression in your clinical cohort. "))),

                        # Input genes
                        column(4,
                            fluidRow(
                                column(12, htmlOutput(ns('Clinical_GeneCorrelation_genes'))),
                                column(12, materialSwitch(ns('Clinical_GeneCorrelation_genes_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                                column(12, 
                                    conditionalPanel( condition = paste0("input['", ns('Clinical_GeneCorrelation_genes_from_custom_geneset'), "'] == true"),
                                        htmlOutput(ns('Clinical_GeneCorrelation_genes_from_custom_geneset_select'))
                                    )
                                ),
                                # show the number of the input 
                                column(12, verbatimTextOutput(ns('Clinical_GeneCorrelation_genes_status')))
                            )
                        ),

                        # Sample filtering for correlation analysis
                        column(4, 
                            fluidRow(
                                column(12, radioButtons(ns('Clinical_Gene_correlation_frequency_filter'), 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                                column(12, htmlOutput(ns('Clinical_Gene_correlation_frequency_filter_selection'))),
                                column(12, htmlOutput(ns('Clinical_Gene_correlation_frequency_filter_selection_category'))),
                                column(12, verbatimTextOutput(ns('Clinical_Gene_correlation_frequency_filter_selection_number')))
                            )
                        ),

                        # Correlation method setting and the start button
                        column(3, 
                            fluidRow(
                                column(12, radioButtons(ns('Gene_correlation_Correlation_method'), 'Method for correlation', choices = c('pearson', 'spearman'),selected='pearson')),
                                column(12, h4('')),
                                column(12, h4('')),
                                column(12, actionButton(ns('Gene_correlation_start'), "Calculate the correlation",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                            )
                        ),
                        column(1,
                            div(id='help',
                                dropdownButton( 
                                fluidRow(
                                    column(12, h4(strong("Quick guide"))),
                                    column(12, 
                                    helpText(
                                        HTML("0. Select a cohort. <br>
                                        1. Select 'Explore type'. <br>
                                        2. Enter ONE gene. This gene's expression will be on the Y-axis. <br>
                                        3. Select the method for correlation. <br>
                                        4. Click the 'Calculate the correlation' button to run the analysis. <br>
                                        5. A table of the p-value and the correlation score for each gene will be displayed in the 'Correlation table' section below. <br>
                                        6. By selecting a gene in the table, a scatter plot will be displayed in the 'Scatter plot' section.
                                        ")
                                        )
                                    ),
                                ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                ),
                            )
                        )
                    ),
                    fluidRow(
                        column(8,  verbatimTextOutput(ns('Gene_correlation_all_status')) )
                    )
                )
            )
        ),
        fluidRow(
            # show the correlation table
            column(4, 
                box(width=12, status='warning', title='Correlation table',
                fluidRow(
                    column(12, h4('') ),
                    column(12, withSpinner(verbatimTextOutput(ns('Gene_correlation_table_status')), type = 5, color = "#0dc5c1" )),
                    column(8, htmlOutput(ns('Gene_correlation_table_gene_select'))),
                    column(4, h4('') ),
                    column(12, withSpinner(DT::dataTableOutput(ns("Gene_correlation_table")), type = 5, color = "#0dc5c1" ) ),
                    column(12, h4('') ),
                    column(12, downloadButton(ns('Gene_correlation_table_download'),"Download this table") )
                )
                )
            ),

            # show the plot
            column(8, 
                box(width=12, status='danger', title='Plot',
                    fluidRow(
                        column(12, h4('') ),
                        column(10, verbatimTextOutput(ns('Gene_correlation_error_catch')) ),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6,sliderInput(ns('Gene_correlation_fig.width'), 'Fig width', min=300, max=3000, value=700, step=10)),
                                    column(6,sliderInput(ns('Gene_correlation_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10)),
                                ),
                                fluidRow(
                                    column(6,sliderInput(ns('Gene_correlation_label_size'), 'X/Y label size', min=0, max=10, value=3, step=0.1)),
                                    conditionalPanel( condition=paste0("input['", ns('Gene_correlation_table_rows_selected'), "'].length > 0"),
                                        column(6,sliderInput(ns('Gene_correlation_title_size'), 'X/Y title size', min=0.1, max=10, value=3, step=0.1))
                                    ),
                                    conditionalPanel( condition=paste0("input['", ns('Gene_correlation_table_rows_selected'), "'].length == 0"),
                                        column(6,sliderInput(ns('Gene_correlation_legend_size'), 'Legend font size', min=0.1, max=5, value=2.5, step=0.1))
                                    )
                                    ),
                                    conditionalPanel( condition=paste0("input['", ns('Gene_correlation_table_rows_selected'), "'].length > 0"),
                                        fluidRow(
                                            column(4, colourpicker::colourInput(ns('Gene_correlation_colour'), 'Colour of the dots:', value='#ec00ec')),
                                            column(4, materialSwitch(ns('Gene_correlation_show_correlation_line'), 'Show the correlation line', value=TRUE, status = "success")),
                                            column(4, materialSwitch(ns('Gene_correlation_white_background'), 'Use white background', value=FALSE, status = "success"))
                                        )
                                    ),
                                    conditionalPanel( condition=paste0("input['", ns('Gene_correlation_table_rows_selected'), "'].length == 0"),
                                        fluidRow( 
                                            column(4, colourpicker::colourInput(ns('Gene_correlation_pairwise_col_low'), 'Colour of the lowest correlation (-1):', value='#2e00fa')),
                                            column(4, colourpicker::colourInput(ns('Gene_correlation_pairwise_col_high'), 'Colour of the highest correlation (1):', value='#ec00ec')),
                                            column(4, colourpicker::colourInput(ns('Gene_correlation_pairwise_col_mid'), 'Colour of the mid correlation (0):', value='#ffffff'))
                                        )
                                ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(12, withSpinner(plotOutput(ns("Gene_correlation_scatter_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
                    )
                )
            )
        )
    )    
}