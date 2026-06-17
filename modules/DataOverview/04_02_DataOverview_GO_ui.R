DataOverview_GO_ui <- function(ns){
    fluidRow(
        column(12, h4('')),


        box(title=strong('Inputs and Settings'), collapsible=TRUE, width=4,status='info',
            fluidRow(
                column(12, helpText("You can perform GO or KEGG enrichment analysis. The genes can be either mannyally inputted, or automatically retrieved from the filtered genes (results from 'Show outliers' above) or selected genes (selected area in the Main plot)."))
            ),

            # Input
            fluidRow(
                column(12, radioButtons(ns("GO_input_type"), "Input genes for the analysis", choices = c("Text input"='A', "Use filtered genes (Results from 'Show outliers' above)"='B', "Use selected genes (Selected area in the Main plot)"='C'), selected="A")),
                conditionalPanel(condition = paste0("input['", ns("GO_input_type"), "'] == 'A'"), 
                    column(12, textAreaInput(ns("GO_input_geneList"), "Enter gene list (one gene per line, Gene symbol)")) 
                ),
                column(10, verbatimTextOutput(ns('GO_input_geneList_status')) ),
                column(12, h4(''))
            ),

            # Species and database selection
            fluidRow(
                column(6, radioButtons(ns("GO_species"), "Select Species", choices = c("Human", "Mouse"), selected="Human")),
                column(6, radioButtons(ns("GO_database"), "Select Database", choices = c("GO", "KEGG"), selected='GO')),
                conditionalPanel(condition = paste0("input['", ns("GO_database"), "'] == 'GO'"), 
                    column(6, radioButtons(ns("GO_ontology"), "Select Ontology", choices = c("BP", "MF", "CC"), selected="BP")) 
                )
            ),

            # Action buttons
            fluidRow( 
                column(12, h5('\n')),
                column(6, actionButton(ns("GO_start"), "Start GO/KEGG Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")), 
                column(6, actionButton(ns("GO_start_reset"), "Reset", style="color: #ffffff; background-color: #615B59; border-color: #000000")), 
                column(12, h5(span('This takes 1~3 minutes depending on the size of the input. Please be patient.', style="color: orange;"))) ,
                column(12, h5('')) 
            )
        ),

        # Results and Plots
        box(title=strong('Results & Plots'), collapsible=TRUE, width=8, status='danger', 
            fluidRow(
                column(12, h4('')),
                column(12, verbatimTextOutput(ns('GO_go_status')) ),
                column(12, h4(''))
            ),
            fluidRow(
                column(12, 
                    tabsetPanel(

                        # Result table
                        tabPanel(strong("Table"), 
                            fluidRow(
                                column(12, h4('')),
                                column(12, verbatimTextOutput(ns('GO_goTable_status')) ),
                                column(12, withSpinner(DT::dataTableOutput(ns("GO_goTable"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                column(12, downloadButton(ns('GO_goTable_download'),"Download this table") )
                            )
                        ),

                        # Bar plot
                        tabPanel(strong("Bar Plot"), 
                            fluidRow(
                                column(12, h4('')),
                                column(10, verbatimTextOutput(ns('GO_goPlot_status')) ),
                                column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6, sliderInput(ns('GO_fig.width'), 'Fig width', min=300, max=3000, value=1000, step=10)),
                                            column(6, sliderInput(ns('GO_fig.height'),'Fig height', min=300, max=3000, value=1000, step=10)),
                                            column(6, sliderInput(ns('GO_fig.category_show_number'),'Number of categories to show', min=5, max=50, value=10, step=1)),
                                            column(6, sliderInput(ns('GO_legend.size'), 'Legend size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_xtitle.font.size'), 'X title font size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_ylab.font.size'), 'Y labels size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_xlab.font.size'), 'X label font size', min=0.1, max=20, value=5, step=0.1))
                                        ),
                                        fluidRow(
                                            column(6, colourpicker::colourInput(ns('GO_bar_colour_max'), 'Max colour:', value='#ffffff')),
                                            column(6, colourpicker::colourInput(ns('GO_bar_colour_min'), 'Min colour:', value='#00c310')),
                                            column(6, materialSwitch(ns('GO_bar_white_background'), 'Use white background', value=FALSE, status='success')),
                                        ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    ),
                                ),
                                column(12, withSpinner(plotOutput(ns("GO_goPlot"), width="100%", height="100%"), type=5, color='#0dc5c1'))
                            )
                        ),

                        # Bubble plot
                        tabPanel(strong("Bubble Plot"), 
                            fluidRow(
                                column(12, h4('')),
                                column(10, verbatimTextOutput(ns('GO_goBubblePlot_status')) ),
                                column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6, sliderInput(ns('GO_Bubble_fig.width'), 'Fig width', min=300, max=3000, value=1000, step=10)),
                                            column(6, sliderInput(ns('GO_Bubble_fig.height'),'Fig height', min=300, max=3000, value=1000, step=10)),
                                            column(6, sliderInput(ns('GO_Bubble_fig.category_show_number'),'Number of categories to show', min=5, max=50, value=10, step=1)),
                                            column(6, sliderInput(ns('GO_Bubble_xtitle.font.size'), 'X title font size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_Bubble_ylab.font.size'), 'Y labels size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_Bubble_xlab.font.size'), 'X label font size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_Bubble_legend.size'), 'Legend size', min=0.1, max=20, value=5, step=0.1))
                                        ),
                                        fluidRow(
                                            column(6, colourpicker::colourInput(ns('GO_Bubble_colour_max'), 'Max colour:', value='#ffffff')),
                                            column(6, colourpicker::colourInput(ns('GO_Bubble_colour_min'), 'Min colour:', value='#c45f00')),
                                            column(6, materialSwitch(ns('GO_Bubble_white_background'), 'Use white background', value=FALSE, status='success')),
                                        ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    ),
                                ),
                                column(12, withSpinner(plotOutput(ns("GO_goBubblePlot"), width="100%", height="100%"), type=5, color='#0dc5c1'))
                            )
                        ),

                        # Network Plot
                        tabPanel(strong("Network plot"), 
                            fluidRow(
                                column(12, h4('')),
                                column(12, helpText("Note: If the plot fails to generate due to insufficient width, click the reset button and increase the width.")),
                                column(10, verbatimTextOutput(ns('GO_netPlot_status_status')) ),
                                column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6, sliderInput(ns('GO_netPlot_fig.width'), 'Fig width', min=300, max=3000, value=700, step=10)),
                                            column(6, sliderInput(ns('GO_netPlot_fig.height'),'Fig height', min=300, max=3000, value=700, step=10)),
                                            column(6, sliderInput(ns('GO_netPlot_category_show_number'), 'Number of categories to show', min=1, max=20, value=5, step=1)),
                                            column(6, sliderInput(ns('GO_netPlot_legend.size'), 'Legend size', min=0.1, max=20, value=5, step=0.1)),
                                            column(6, sliderInput(ns('GO_netPlot_edge_size_term'), 'Edge line width', min=0.01, max=2, value=0.2, step=0.01)),
                                        ),
                                        fluidRow(
                                            column(6, sliderInput(ns('GO_netPlot_label_size_term_term'), 'Node label size (Term name)', min=0, max=5, value=2, step=0.1)),
                                            column(6, sliderInput(ns('GO_netPlot_label_size_term_gene'), 'Node label size (Gene)', min=0, max=5, value=0, step=0.1)),
                                            column(6, sliderInput(ns('GO_netPlot_node_size_term'), 'Node size (Term name)', min=0.1, max=10, value=2, step=0.1)),
                                            column(6, sliderInput(ns('GO_netPlot_node_size_gene'), 'Node size (Gene)', min=0.1, max=10, value=1, step=0.1)),
                                            # colour of the node
                                            column(6, colourpicker::colourInput(ns('GO_netPlot_node_colour_term'), 'Node colour (Term name):', value='#d3a200')),
                                            column(6, colourpicker::colourInput(ns('GO_netPlot_node_colour_gene'), 'Node colour (Gene):', value='#292929'))
                                        ),
                                        fluidRow(
                                            column(6, materialSwitch(ns('GO_netPlot_change_edge_colour'), 'Change edge colour by terms', value=FALSE, status='success')),
                                            column(6, materialSwitch(ns('GO_netPlot_circle_plot'), 'Circle plot', value=FALSE, status='success')),
                                        ),circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    ),
                                ),
                                column(12, 
                                    div(style='position: relative;',
                                        withSpinner(plotOutput(ns("GO_netPlot"),  brush = "plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1')
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