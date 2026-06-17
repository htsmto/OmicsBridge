Epigenome_genomevisualisation_UI <- function(ns){
    box(title='Profile Plot', width=12, status='primary', solidHeader = TRUE,
        fluidRow(
        column(4,
            box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
            fluidRow(
                column(12, htmlOutput(ns('Gviz_data_select'))),
                column(12, radioButtons(ns('Gviz_data_type'), 'Data type', choices=c('BigWig', 'BAM'), selected='BigWig', inline=TRUE)),
                column(12, actionButton(ns('Gviz_data_add'), 'Use this dataset', style="color: #ffffff; background-color: #33c481; border-color: #04915e") ),
                column(12, h2('')),
                column(12, verbatimTextOutput(ns('Gviz_selected_dataset_status')) ),
                column(12, h2('')),
                column(12, h5(strong('Selected datasets:'))),
                column(12, helpText('The following datasets are used for the genome visualisation.')),
                column(12, DT::dataTableOutput(ns('Gviz_selected_dataset'))),
                column(12, actionButton(ns('Gviz_data_delete'), 'Remove the dataset from the list', style="color: #ffffff; background-color:#0e98e8; border-color: #0772b0") ),
                column(12, verbatimTextOutput(ns('Gviz_selected_dataset_delete_status')) ),
            )
            )
        ),
        column(8,
            box(width=12, title='Plot', status='danger', collapsible = TRUE,
            fluidRow(
                column(4, selectInput(ns('Gviz_genome_selection'), 'Choose genome:', choices=c('hg38', 'hg19'), selected='hg38')),
                column(4, textInput(ns('Gviz_chromosome_pos'), 'Position', value='chr1:1000000-2000000')),
                column(4, 
                fluidRow(
                    column(12, h2('')),
                    column(12, actionButton(ns('Gviz_plot_start'), 'Show a plot', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                )
                ),
                column(12, verbatimTextOutput(ns('Gviz_plot_status')) ),
                column(10, 
                helpText(HTML("Note: <br>
                    1. When using BAM files, a wide range (e.g., >100k–200k bp) can cause a memory error and stop the interface (This issue does not occur when using only BigWig files.) <br>
                    2. If the sample label is missing, try increasing the height of the figure and re-plotting."))
                ),
                column(2, 
                dropdownButton( h4(strong("Plot Options")),
                    fluidRow(
                    column(6, sliderInput(ns('Gviz_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10)),
                    column(6, sliderInput(ns('Gviz_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10)),
                    ),
                    fluidRow(
                    column(12, h5(strong('For the following, please re-run the plot'))),
                    column(6, colourpicker::colourInput(ns('Gviz_plot_bw_col'), 'The colour for the bigwig data', value="#3c6602")),
                    column(6, colourpicker::colourInput(ns('Gviz_plot_bam_col'), 'The colour for the bam data', value="#f21392")),
                    column(6, colourpicker::colourInput(ns('Gviz_plot_refseq_col'), 'The colour for the reference data', value="#311fbf")),
                    ),
                    fluidRow(
                    column(6, numericInput(ns('Gviz_plot_height_bw'), 'The height of the bigwig data', min=1, value=20, step=1)),
                    column(6, numericInput(ns('Gviz_plot_height_bam'), 'The height of the bam data', min=1, value=30, step=1)),
                    column(6, numericInput(ns('Gviz_plot_height_ref'), 'The height of the reference data', min=1, value=20, step=1))
                    ),
                    fluidRow(
                    column(6, materialSwitch(ns('Gviz_plot_ylim_bw'), 'Use Y-axis limit for the bigwig data', value=FALSE, status = "success")),
                    conditionalPanel(condition = paste0("input['", ns('Gviz_plot_ylim_bw'), "'] == true"),
                        column(6, numericInput(ns('Gviz_plot_ylim_bw_max'), 'Max Y-axis:', value=1, step=1)),
                    )
                    ),
                    fluidRow(
                    column(6, materialSwitch(ns('Gviz_plot_ylim_bam'), 'Use Y-axis limit for the bam data', value=FALSE, status = "success")),
                    conditionalPanel(condition = paste0("input['", ns('Gviz_plot_ylim_bam'), "'] == true"),
                        column(6, numericInput(ns('Gviz_plot_ylim_bam_max'), 'Max Y-axis:', value=50, step=1)),
                    )
                    ),
                    circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                )
                ),
                column(12, withSpinner(plotOutput(ns("Gviz_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1") ),
                column(12, helpText(paste("Visualised by the Gviz library. Version: ", installed.packages()["Gviz", "Version"])))
            )
            )
        )
        )
    )
}