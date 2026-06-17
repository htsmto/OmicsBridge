DataOverview_TF_ui <- function(ns){
    fluidRow(
        column(12, helpText(strong('   Note: This module is available only for RNAseq DEG data processed from DESeq2')) ),

        # Setting and start
        column(4, 
            box(title='Settings', collapsible=TRUE, width=12, status='info',
                fluidRow(
                    column(12, helpText("Here you can estimate the activity of transcription factors (TFs) based on the expression changes of their target genes. \nThis analysis uses the DecoupeR method, which integrates gene expression data with TF-target interactions to infer TF activity. \nPlease select the number of TFs to display in the results and click the 'Start DecoupeR Analysis' button to begin. \nThe results will include a plot of TF activities and a table of TFs with their corresponding activity scores.")),
                    column(12, h5('\n')),
                    column(10, sliderInput(ns('DecoupeR_TF_number'), 'Number of TF to display', min=10, max=200, value=50, step=1)),
                    column(12, actionButton(ns("DecoupeR_start"), "Start DecoupeR Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                )
            ),
        ),

        # Plot and result
        column(8, 
            box(title='Plots & Results', collapsible=TRUE, width=12, status='danger',

                fluidRow(
                    column(12, helpText("Note: This is only applicable to the RNAseq DEG data processed by DESeq2. Please see the wiki for more details.")),
                    column(12, verbatimTextOutput(ns('DecoupeR_plot_status')) )
                ),


                tabsetPanel(

                    # Plot
                    tabPanel("DecoupeR Plot",
                        fluidRow(
                            column(12, h2('')),
                            column(10, verbatimTextOutput(ns('DecoupeR_plot_status2')) ),
                            column(2, 
                                dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                        column(6, sliderInput(ns('DecoupeR_fig.width'), 'Fig width', min=500, max=4000, value=1000, step=10)),
                                        column(6, sliderInput(ns('DecoupeR_fig.height'),'Fig height', min=300, max=3000, value=500, step=10))
                                    ),
                                    fluidRow(
                                        column(6, sliderInput(ns('DecoupeR_lab.font.size'), 'X/Y labels size', min=1, max=10, value=3, step=0.1)),
                                        column(6, sliderInput(ns('DecoupeR_title.font.size'), 'X/Y title font size', min=1, max=10, value=3, step=0.1)),
                                        column(6, sliderInput(ns('DecoupeR_legend.size'), 'Legend size', min=1, max=10, value=3, step=0.1)),
                                    ),
                                    fluidRow(
                                        column(4, colourpicker::colourInput(ns('DecoupeR_colour_high'), 'High activity colour:', value='indianred')),
                                        column(4, colourpicker::colourInput(ns('DecoupeR_colour_low'), 'Low activity colour:', value='darkblue')),
                                        column(4, colourpicker::colourInput(ns('DecoupeR_colour_mid'), 'Zero activity colour:', value='whitesmoke')),
                                        column(12, materialSwitch(ns('DecoupeR_white_background'), 'Use white background', value=FALSE, status='success'))
                                    ),circle = FALSE, status = "success", icon = icon("gear"), right=TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                            ),
                            column(12, withSpinner(plotOutput(ns("DecoupeR_plot"), width="100%", height="100%"), type=5, color='#0dc5c1' )  )
                        )
                    ),

                    # Table
                    tabPanel("Results Table", 
                        fluidRow(
                            column(12, h2('')),
                            column(12, verbatimTextOutput(ns('DecoupeR_Table_status')) ),
                            column(12, withSpinner(DT::dataTableOutput(ns("DecoupeR_Table"), width="100%", height="100%"), type=5, color='#0dc5c1')),
                            column(12, h5('')) ,
                            column(12, downloadButton(ns('DecoupeR_Table_download'),"Download this table") )
                        )
                    )
                )
            )
        )
    )   
}