DataOverview_GSEA_ui <- function(ns){
    fluidRow(
        column(12, h4('')),

        # Input and Settings
        column(12, 
            box(width=12, collapsible=TRUE, title=strong('Settings'), status='info',
                fluidRow(
                    column(12, helpText(HTML('Here you can perform Gene Set Enrichment Analysis (GSEA) using the ranked gene list generated from the selected dataset. <br>Please note that the gene symbols in your input data should match those in the selected gene sets for accurate analysis.'))),
                    column(10,
                        fluidRow(

                            # choose 
                            column(5, 
                                fluidRow(
                                    column(12, radioButtons(ns("GSEA_pathway_dataset_select"), "Pathways from", choices = c("HALLMARK (Human)"='B', "HALLMARK (Mouse)"='C', "Upload a gmt file (other gene sets)"='D', "Calculate the enrichment of one gene set"='E'), selected="B")),
                                    column(12, verbatimTextOutput(ns('GSEA_pathway_dataset_select_status'))),
                                )
                                
                            ),

                            # how to rank
                            column(6, htmlOutput(ns("GSEA_select_score"))),

                            # if you need to upload a gmt file
                            conditionalPanel( condition = paste0("input['", ns("GSEA_pathway_dataset_select"), "'] == 'D'"), 
                                column(7, fileInput(ns("GSEA_upload_custom_pathway_file"), "Upload a gmt file")) 
                            ),

                            # custom gene set selection
                            conditionalPanel( condition = paste0("input['", ns("GSEA_pathway_dataset_select"), "'] == 'E'"), 
                                column(7, 
                                    fluidRow(
                                        column(12, radioButtons(ns('GSEA_pathway_dataset_select_one_geneset_select'), '', choices=c("Choose from the Custom Gene sets"= 'A', "Text input"='B'), selected='A')),
                                        column(12, 
                                            conditionalPanel(condition = paste0("input['", ns("GSEA_pathway_dataset_select_one_geneset_select"), "'] == 'A'"), 
                                                htmlOutput(ns('GSEA_pathway_dataset_select_one_geneset_select_from_custom_set'))
                                            )
                                        ),
                                        column(12, 
                                            conditionalPanel(condition = paste0("input['", ns("GSEA_pathway_dataset_select_one_geneset_select"), "'] == 'B'"), 
                                                textAreaInput(ns('GSEA_pathway_dataset_select_one_geneset_select_from_text'), 'Enter genes (line by line)')
                                            )
                                        )
                                    )
                                )
                            )
                        ),

                        # start GSEA analysis
                        fluidRow( 
                            column(3, actionButton(ns("GSEA_start"), "Start GSEA Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                            column(9, verbatimTextOutput(ns('GSEA_analysis_status')))
                        )
                    )
                )
            )        
        ),


        # results table and plot
        column(12,
            box(title=strong('GSEA Results Table'), collapsible=TRUE, width=4, status='warning',
                fluidRow( 
                    column(12, verbatimTextOutput(ns('GSEA_goTable_status'))),
                    column(12, withSpinner(DT::dataTableOutput(ns("GSEA_goTable"), width="100%", height="100%"), type=5, color='#0dc5c1') ), 
                    column(12, downloadButton(ns('GSEA_download'),"Download this table") )
                )
            ),
            box(title=strong('Plots'), collapsible=TRUE, width=8, status='danger',
                fluidRow( 
                    column(10, verbatimTextOutput(ns('GSEA_status'))),
                    column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(4, sliderInput(ns('GSEA_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                column(4, sliderInput(ns('GSEA_fig.height'),'Fig height', min=300, max=3000, value=500, step=10))
                            ),
                            fluidRow(
                                column(4, sliderInput(ns('GSEA_lab.font.size'), 'X/Y labels size', min=1, max=15, value=5, step=0.1)),
                                column(4, sliderInput(ns('GSEA_title.font.size'), 'X/Y title font size', min=1, max=15, value=5, step=0.1)),
                                column(4, sliderInput(ns('GSEA_graph_title.font.size'), 'Graph title font size', min=1, max=15, value=5, step=0.1))
                            ),
                            fluidRow(
                                column(4, colourpicker::colourInput(ns('GSEA_graph_line_colour'), 'GSEA line colour:', value='green')),
                                column(4, colourpicker::colourInput(ns('GSEA_graph_maxmin_line_colour'), 'Max/Min line colour:', value='red'))
                            ), circle = FALSE, status = "success", icon = icon("gear"), width = "1000px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                        ),
                    ),
                    column(12, withSpinner(plotOutput(ns("GSEA_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') )
                )
            )
        )

    )
}