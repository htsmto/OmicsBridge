Epigenome_motifScan_UI <- function(ns){
    box(title='Motif Scan', width=12, status='primary', solidHeader = TRUE,
        fluidRow(
            
            # Input and settings
            column(4,
                box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                    fluidRow(
                        column(12, helpText("This tool scans for motifs in the input peaks or sequences with the MotifDb database (PWMLogn.hg19.MotifDb.Hsap), identifying potential transcription factor binding sites within the specified genomic region.")),
                        column(12, radioButtons(ns('Motif_analysis_input_type'), 'Input type', choices = c('Input genomic positions'='A', 'Input sequences'='B'), selected='A', inline=TRUE)),
                        column(12, htmlOutput(ns('Motif_analysis_input_type_peaks'))),
                        column(12, htmlOutput(ns('Motif_analysis_input_type_gene'))),
                        column(12, h2('')),
                        column(4, actionButton(ns('Motif_analysis_start'), 'Start motif scan', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                        column(8, helpText('It may take a while to finish the motif scan. Please be patient after clicking the button.'))
                    )
                )
            ),

            # Results
            column(8,

                # Table
                fluidRow(
                    column(12, 
                        box(width=12, title='Motifs', status='warning', collapsible = TRUE,
                            fluidRow(
                                column(12, verbatimTextOutput(ns('Motif_analysis_status')) ),
                                column(12, withSpinner(DT::dataTableOutput(ns('Motif_analysis_table')), type = 5, color = "#0dc5c1") ),
                                column(3, downloadButton(ns('Motif_analysis_table_download'), 'Download motif table', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                                column(5,
                                    box(width=12, title='Significant motifs', collapsible = TRUE, collapsed = TRUE, status='success',
                                        fluidRow(
                                            column(12, h5('')),
                                            column(10, numericInput(ns('Motif_analysis_significant_threshold'), 'Significant threshold', value=0.05, min=0, step=0.001)),
                                            column(2, h4('')),
                                            column(11, verbatimTextOutput(ns('Motif_analysis_significant_motif_list'))),
                                        )
                                    )
                                )
                            )
                        )
                    )
                ),

                # Plot
                fluidRow(
                    column(12, 
                        box(width=12, title='Plot (logo)', status='danger', collapsible = TRUE,
                            fluidRow(
                                column(10, verbatimTextOutput(ns('Motif_analysis_plot_status'))),
                                column(2,
                                    dropdownButton( 
                                        h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6, sliderInput(ns('Motif_analysis_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10)),
                                            column(6, sliderInput(ns('Motif_analysis_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                            column(6, sliderInput(ns('Motif_analysis_plot_XY_label_size'), 'X/Y label size', min=0.1, max=10, value=3, step=0.1)),
                                            column(6, sliderInput(ns('Motif_analysis_plot_XY_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1))
                                        ),
                                        fluidRow(
                                            column(6, radioButtons(ns('Motif_analysis_plot_Y_axis'), 'Y axis:', choices = c('bits','prob'), selected = 'bits', inline=TRUE))
                                        ),circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                ),
                                column(12, withSpinner(plotOutput(ns('Motif_analysis_plot'), width='100%', height='100%'), type = 5, color = "#0dc5c1") )
                            )
                        )
                    )
                )
            )
        )
    )
}