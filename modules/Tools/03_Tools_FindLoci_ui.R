tools_findloci_UI <- function(ns){
    tagList(
        # Find gene positions/annotations
        box(width=12, status='primary',  solidHeader = TRUE, title='Find Gene Positions/Annotations',
            fluidRow(
                # Input and settings
                column(4, 
                    box(width=12, title='Inputs and Settings', status= 'info',collapsible = TRUE,
                        fluidRow(
                            column(12, helpText(HTML("This tool finds the genomic coordinates of input genes, or finds the genes located in the input genomic regions. <br>Please select the method, enter the gene names or genomic coordinates (line by line), and choose the genome. Then click the 'Search' button to get the results."))),
                            column(5, radioButtons(ns("Find_genome_loci_direction"), "Choose the method", 
                                choices = c(
                                    'Input genes and find the coordinates' = 'A', 
                                    'Input coordinates and find the genes' = 'B'), 
                                selected='A')),
                            column(5, radioButtons(ns("Choose_genome"), "Choose genome", choices = c("hg38"))),
                            column(2, h4('\n')),
                            column(12, textAreaInput(ns('Find_genome_loci_input'), 'Enter gene names or coordinates (line by line)')),
                            column(12, h4('\n')),
                            column(12, verbatimTextOutput(ns('Find_genome_loci_status_input')) ),
                            column(4, actionButton(ns('Find_genome_loci_start'), 'Search', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                        )
                    )
                ),

                # results table
                column(5,
                    box(width=12, title='Search Results', status='danger',collapsible = TRUE,
                        fluidRow(
                            column(12, verbatimTextOutput(ns('Find_genome_loci_status_table')) ),
                            column(12, withSpinner(DT::dataTableOutput(ns('Find_genome_loci_table')), type = 5, color = "#0dc5c1") ),
                            column(12, downloadButton(ns('Find_genome_loci_table_download'),"Download this table"))
                        )
                    )
                ),

                # result list
                column(3,
                    box(width=12, title='List of Genes/Coordinates', status='warning',collapsible = TRUE,
                        fluidRow(
                        column(12, verbatimTextOutput(ns('Find_genome_loci_status_result')) )
                        )
                    )
                )
            )
        ),

        # Peak annotation
        box(width=12, status='primary', solidHeader = TRUE, title='Peak Annotation',
            fluidRow(
                # Input and settings
                column(4,
                    box(width=12, status='info', title='Inputs and Settings',
                        fluidRow(
                            column(12, helpText(HTML("This tool annotates the genomic locations of input peaks, and finds the nearest genes. <br>Please enter the peak regions (chr:start-end, line by line), choose the genome, and click the 'Annotate' button to get the results."))),
                            column(12, textAreaInput(ns("Peak_annotation_input"), "Enter peak regions (chr:start-end)",placeholder = 'chr1:100000-100100')),
                            column(12, radioButtons(ns("Peak_annotation_genome"), "Choose genome", choices = c("hg38"))),
                            column(12, h3('')),
                            column(12, verbatimTextOutput(ns('Peak_annotation_status_input'))),
                            column(12, actionButton(ns('Peak_annotation_start'), "Annotate the genomic locations", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                        )
                    )
                ),

                # Results table
                column(8,
                    box(width=12, status='warning', title='Annotation Result',
                        column(12, verbatimTextOutput(ns('Peak_annotation_status_results'))),
                        column(12, h4('')),
                        column(12,

                            # Three results: 1. annotation table, 2. annotation distribution plot, 3. nearest gene names list
                            tabsetPanel(

                                # Result1: annotation table
                                tabPanel("Table", 
                                    fluidRow(
                                        column(12, h4('')),
                                        column(12, verbatimTextOutput(ns('Peak_annotation_table_status')) ),
                                        column(12, withSpinner(DT::dataTableOutput(ns('Peak_annotation_table')), type = 5, color = "#0dc5c1") ),
                                        column(12, downloadButton(ns('Peak_annotation_table_download'),"Download this table"))
                                    )
                                ),

                                # Result2: annotation distribution plot
                                tabPanel("Plots",
                                    fluidRow(
                                        column(12, h4('')),
                                        column(12, verbatimTextOutput(ns('Peak_annotation_plot_status')) ),
                                        column(9, radioButtons(ns('Peak_annotation_plot_type'), 'Choose plot type', choices = c('Pie Plot'='A', 'Bar Plot'='B'), inline=TRUE)),
                                        column(3,
                                            dropdownButton( h4(strong("Plot Options")),
                                                fluidRow(
                                                    column(6, sliderInput(ns('Peak_annotation_plot.width'), 'Fig width', min=300, max=3000, value=900, step=10) ),
                                                    column(6, sliderInput(ns('Peak_annotation_plot.height'), 'Fig height', min=300, max=3000, value=700, step=10) ),
                                                    column(6, sliderInput(ns('Peak_annotation_legend.title.size'), 'Legend title size', min=0.1, max=10, value=4, step=0.1) ),
                                                    column(6, sliderInput(ns('Peak_annotation_legend.text.size'), 'Legend text size', min=0.1, max=10, value=4, step=0.1) ),
                                                    conditionalPanel(condition = paste0("input['", ns("Peak_annotation_plot_type"), "'] == 'B'"),
                                                        column(6, sliderInput(ns('Peak_annotation_plot.X.size'), 'X axis font size', min=0.1, max=10, value=4, step=0.1) ),
                                                    )
                                                ),circle = FALSE, status = "success", icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                            ),
                                        ),
                                        column(12, withSpinner(plotOutput(ns("Peak_annotation_plot"),  width="100%", height="100%"), type=5, color='#0dc5c1') )
                                    )
                                ),

                                # Result3: nearest gene names list          
                                tabPanel("Nearest Gene Names List",
                                    fluidRow(
                                        column(12, h4('')),
                                        column(12, verbatimTextOutput(ns('Peak_annotation_genes_list_status')) ),
                                        column(12, radioButtons(ns('Peak_annotation_genes_list_type'), 'Gene name type:', choices = c('GeneID'='A', 'Symbol'='B'), inline=TRUE)),
                                        column(6,   withSpinner(verbatimTextOutput(ns('Peak_annotation_genes_list')), type=5, color='#0dc5c1'))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}