dataoverview_heatmap_UI <- function(ns){
    tagList(
        fluidRow(
            column(12, h4('\n'))
        ), 
        fluidRow(

            # Inputs and Settings
            column(4,

                # Inputs
                box(width=12, collapsible=TRUE, status='info', title=strong('Inputs and Settings'),

                    # Gene Input
                    fluidRow(
                        column(12, helpText('Please input the target genes and select the samples to use. The gene expression scores will be standardised (z-score) across the selected samples.')),
                        column(12, h4(HTML('<u>Set the input genes</u>'))),
                        column(12, radioButtons(ns('Data_Overview_heatmap_target_gene_type'), 'Genes from:', 
                            choices = c('Text input'='A', 'Custom Gene Sets'='B', 'HALLMARK (Human)'='C', 'HALLMARK (Mouse)'='D', 'Input a gmt file'='E'), selected='A'),
                            inline = TRUE
                        ),
                        column(12, htmlOutput(ns("Data_Overview_heatmap_target_select_geneset"))),
                        column(12, verbatimTextOutput(ns('Data_Overview_heatmap_target_gene_type_status')))
                    ),

                    # Sample selection
                    fluidRow(
                        column(12, h4(HTML('<br><u>Select the samples</u>'))),
                        column(12, verbatimTextOutput(ns('Data_Overview_heatmap_sample_table_status'))),
                        column(12, dataTableOutput(ns("Data_Overview_heatmap_sample_table")))
                    ),

                    # start button
                    fluidRow(
                        column(12, actionButton(ns('Gene_Overview_heatmap_start'), 'Generate a heatmap', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                    )
                    #
                )
                #
            ),

            # Plot
            column(8, 
                box(width=12, collapsible=TRUE, status='danger', title=strong('Plot'),
                fluidRow(
                    # status
                    column(10, verbatimTextOutput(ns('Data_Overview_heatmap_status')) ),
                    column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6, sliderInput(inputId = ns('Data_Overview_heatmap_fig.width'), label='Fig width', min=300, max=3000, value=700, step=10)),
                                column(6, sliderInput(inputId = ns('Data_Overview_heatmap_fig.height'), label='Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(inputId = ns('Data_Overview_heatmap_xlab.font.size'), label='X label size', min=0, max=10, value=1, step=0.1)),
                                column(6, sliderInput(inputId = ns('Data_Overview_heatmap_ylab.font.size'), label='Y label size', min=0, max=10, value=3, step=0.1)),
                                column(6, sliderInput(inputId = ns('Data_Overview_heatmap_legend.size'), label='Legend size', min=1, max=10, value=3, step=1)),
                            ),
                            fluidRow(
                                column(4, colourpicker::colourInput(inputId = ns('Data_Overview_heatmap_col_high'), 'Colour for the highest value', value='red')),
                                column(4, colourpicker::colourInput(inputId = ns('Data_Overview_heatmap_col_low'), 'Colour for the lowest value', value='blue')),
                                column(4, colourpicker::colourInput(inputId = ns('Data_Overview_heatmap_col_mid'), 'Colour for value = 0', value='white')),
                            ),
                            fluidRow(
                                column(12, materialSwitch(ns('Data_Overview_heatmap_white_background'), 'Use white background', value=FALSE, status = "success"))
                            ),circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                    ),
                    column(12, h4('\n')),
                    column(12, withSpinner(plotOutput(ns("Data_Overview_heatmap_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                    column(12, h4('\n')),
                    column(6, sliderInput(inputId = ns('Cluster_num'), label='Cluster number', min=1, max=20, value=1, step=1)),
                )
                )
            )
        ),
        fluidRow(

            # table
            column(12, 
                box(title=strong('Expression scores'), collapsible=TRUE, status='warning', width=12, 
                    fluidRow(
                        column(12, verbatimTextOutput(ns('Data_Overview_heatmap_expression_status')) ),
                        column(12, dataTableOutput(ns("Data_Overview_heatmap_expression")))
                    ),
                    fluidRow(
                        column(3, downloadButton(ns('Data_Overview_heatmap_expression_download'),"Download this table", style="color: #ffffff; background-color: #ee9d29; border-color: #e48803")),
                        column(4, 
                        box(width=12, title='List of the genes in each cluster.', collapsible=TRUE, collapsed=TRUE,
                            fluidRow(column(12, htmlOutput(ns('Data_Overview_heatmap_expression_cluster_select')))),
                            fluidRow(column(12, verbatimTextOutput(ns('Data_Overview_heatmap_expression_cluster_genename'))))
                        )
                        )
                    )
                )
            )
        )
    )

}