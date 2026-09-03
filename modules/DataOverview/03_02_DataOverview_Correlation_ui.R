dataoverview_correlation_UI <- function(ns){
    tagList(
        fluidRow(
            column(12, h4('\n'))
        ),   
        fluidRow(
            # Input, Setting, and Table
            column(4,

                # Input
                box(width=12, status='info', title=strong('Inputs and Settings'), collapsible = TRUE,

                    # Gene Input
                    fluidRow(
                        column(12, helpText('Here you can explore the correlation of gene expression in your dataset. The correlation will be calculated pairwise and displayed in a table. By selecting a gene pair in the table, a scatter plot will be generated to show the correlation between the two genes.')),
                        column(12, h4(HTML('<u>Set the input genes</u>'))),
                        column(12, htmlOutput(ns('Two_gene_corr_input'))),
                        column(12, materialSwitch(ns('Two_gene_corr_input_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                        column(12, htmlOutput(ns('Two_gene_corr_input_from_custom_geneset_select'))),
                        column(12, verbatimTextOutput(ns('Two_gene_corr_genes_status')))
                    ),

                    # Method
                    fluidRow(
                        column(12, h4('') ),
                        column(12, h4(HTML('<br><u>Correlation settings</u>'))),
                        column(5, radioButtons(ns('Two_gene_corr_Correlation_method'), "Correlation calculation method", choices=c('pearson', 'spearman'), selected='pearson')),
                        column(7, h3('\n'), materialSwitch(ns("Two_gene_corr_log"), "Use log scale", value=FALSE, status='info')),
                        column(12, h4('') )
                    ),

                    # sample selection
                    fluidRow(
                        column(12, h4(HTML('<br><u>Select the samples</u>'))),
                        column(12, verbatimTextOutput(ns('Two_gene_corr_sample_table_status'))),
                        column(12, dataTableOutput(ns("Two_gene_corr_sample_table")))
                    ),

                    # start button
                    fluidRow(
                        column(12, actionButton(ns('Two_gene_corr_start_pairwise'), 'Calculate correlations',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                        column(12, h4('') ),
                        column(12, verbatimTextOutput(ns('Two_gene_corr_status')) )
                    )

                ),

                # Result table
                box(width=12, status='warning', title=strong('Correlation table'), collapsible = TRUE,
                    fluidRow(
                        column(12, h4('') ),
                        column(12, withSpinner(verbatimTextOutput(ns('Two_gene_corr_table_status')), type = 5, color = "#0dc5c1" )),
                        column(8, htmlOutput(ns('Two_gene_corr_table_gene_select'))),
                        column(4, h4('') ),
                        column(12, withSpinner(DT::dataTableOutput(ns("Two_gene_corr_table")), type = 5, color = "#0dc5c1" ) ),
                        column(12, h4('') ),
                        column(12, downloadButton(ns('Two_gene_corr_table_download'),"Download this table") )
                    )
                )
            ),

            # Plot
            column(8,
                box(width=12, status='danger', title=strong('Plot'), collapsible = TRUE,
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Two_gene_corr_corr_score')) ),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6, sliderInput(ns('Two_gene_corr_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                    column(6, sliderInput(ns('Two_gene_corr_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                    column(6, sliderInput(ns('Two_gene_corr_legend.font.size'), 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput(ns('Two_gene_corr_label.font.size'), 'X/Y label font size', min=0, max=10, value=4, step=0.1)),
                                    conditionalPanel( condition=paste0("input['", ns('Two_gene_corr_table_rows_selected'), "'].length > 0"),
                                        column(6, sliderInput(ns('Two_gene_corr_title.font.size'), 'X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput(ns('Two_gene_corr_pt.size'), 'Point size', min=0.01, max=5, value=1, step=0.01)),
                                        column(6, materialSwitch(ns('Two_gene_corr_white_background'), 'Use white background', value=FALSE, status = "success")),
                                        column(6, materialSwitch(ns('Two_gene_corr_plot_line'), 'Show the correlation line', value=FALSE, status='success') ),
                                        column(6, materialSwitch(ns('Two_gene_corr_plot_Use_single_colour'), 'Use single colour for all points', value=FALSE, status='success') ),
                                        conditionalPanel( condition=paste0("input['", ns('Two_gene_corr_plot_Use_single_colour'), "'] == true"),
                                            column(6, colourpicker::colourInput(ns('Two_gene_corr_colour'), 'Colour of the dots:', value='#ec00ec'))
                                        )
                                    ),   
                                    conditionalPanel( condition=paste0("input['", ns('Two_gene_corr_table_rows_selected'), "'].length == 0"),
                                        column(6, colourpicker::colourInput(ns('Two_gene_corr_pairwise_col_high'), 'Colour for the highest correlation (1)', value='red')),
                                        column(6, colourpicker::colourInput(ns('Two_gene_corr_pairwise_col_low'), 'Colour for the lowest correlation (-1)', value='blue')),
                                        column(6, colourpicker::colourInput(ns('Two_gene_corr_pairwise_col_mid'), 'Colour for zero', value='white'))
                                    )
                                ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                            )
                        ),
                        column(12, withSpinner(plotOutput(ns("Two_gene_corr_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') )
                    )
                )
            )
        )
    )
}