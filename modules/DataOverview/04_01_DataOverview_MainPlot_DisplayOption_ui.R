DataOverview_MainPlot_DisplayOption_ui <- function(ns){
    tagList(
        ## Display options
        box( title=strong('Display Options'),  collapsible=TRUE, status='info',width=12,
            fluidRow(
                column(12, helpText("Please choose the X and Y axis for the scatter plot. \nYou can quickly find the genes of interest by entering the gene names. "))
            ),

            ## select x and y
            fluidRow( 
                column(12, h4(HTML('<u>Choose X and Y axis:</u>'))),
                column(6, htmlOutput(ns("Scat.X"))), 
                column(6, htmlOutput(ns("Scat.Y"))),
            ),

            ## Find the genes of interest
            fluidRow(
                column(12, h4(HTML('<u>Find the genes of interest:</u>'))),
                column(6, textAreaInput(ns("target_gene"), "Enter genes (line by line)")),
                column(6,
                    fluidRow(
                        column(12, h2('')),
                        column(8, colourpicker::colourInput(ns('interesting_gene_colour_id'), 'select colour:', value='red'))
                    )
                ),
                column(12, verbatimTextOutput(ns('Scatter_interesting_gene_status')) ),
            ),

            ## Find the genes of interest (other colour)
            fluidRow(
                column(12, h5('\n')),
                column(12, materialSwitch(ns("main_plot_target_genes_2"), "Highlight other genes with a different colour", value=FALSE, status='info')),
                conditionalPanel(
                    condition = paste0("input['", ns("main_plot_target_genes_2"), "'] == true"),
                    column(12, 
                    fluidRow(
                        column(6, textAreaInput(ns("main_plot_target_genes_2_input"), "Enter genes (line by line)")),
                        column(6,
                            fluidRow(
                                column(12, h2('')),
                                column(8, colourpicker::colourInput(ns('main_plot_target_genes_2_colour'), 'select colour:', value='#0066ff'))
                            )
                        ),
                        column(12,  verbatimTextOutput(ns('Scatter_interesting_gene_status2')) )
                    )
                    )
                )
            ), 

            ## other options
            fluidRow(
                column(12, h5('\n')),
                column(12, materialSwitch(ns("show_label"), "show gene names in the plot", value=FALSE, status='info')),
                column(12, materialSwitch(ns("show_entered_gene_info"), "show the highlighted genes information as a table", value=FALSE, status='info'))
            )
        ), 

        ## filtering options
        box(width=12, collapsible=TRUE, status='info', title='Highlight filterd genes or gene sets in the plot',
            fluidRow(
                column(12, helpText("You can highlight the filtered genes by setting the thresholds, or highlight the genes in a specific pathway or custom gene sets.")),
                column(12, radioButtons(ns("show_filterin_input_option"), "Please Choose one below:", choices=c("None"="A", "Filtered genes"="B", "Pathway genes"="C", "Custom genesets"="D"), selected="A", inline=TRUE),)
            ),

            ## filtered genes/pathway genes/custom gene sets options. 
            ## Common option -> hide labels, change the colour, sho in a bar plot
            conditionalPanel( condition = paste0("input['", ns("show_filterin_input_option"), "'] != 'A'"),

                ## Filtered genes
                conditionalPanel( condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'B'"),

                    # how to set the threshold for filtering
                    fluidRow(
                        column(12, h3('\n')),
                        column(12, helpText("You can filter the genes by setting the threshold for top/bottom N % sorted by the X axis or by setting custom thresholds for X and Y axis.")),
                        column(12, radioButtons(ns("How_to_filter"), "How to filter:", choices = c("Show top/bottom N % (default: 10%)"="A", "Custom threshold setting"="B"), selected='B')),
                    ),

                    # top/bottom N % filtering
                    conditionalPanel( condition = paste0("input['", ns("How_to_filter"), "'] == 'A'"), # take top/bottom N %
                        fluidRow(
                            column(12, h3('\n')),
                            column(6, numericInput(ns('Overviwe_Top_threshold'), 'The threshold for Top hits (%)', min=0, max=100, value=10, step=1)),
                            column(6, numericInput(ns('Overviwe_Bottom_threshold'), 'The threshold for Bottom hits (%)', min=0, max=100, value=10, step=1)),
                            column(6, numericInput(ns('Overviwe_Top_bottom_Y_threshold'), 'The threshold for Y axis', min=0, value=0, step=0.1)),
                            column(12, h3(''))
                        )
                    ),

                    # custom threshold setting
                    conditionalPanel( condition = paste0("input['", ns("How_to_filter"), "'] == 'B'"),
                        fluidRow(
                            column(12, h3('\n')),
                            column(3,
                                fluidRow(
                                column(12, numericInput(ns('Main_scatter_thr_X1'), 'X threshold 1',  value=1, step=0.1) ),
                                column(12, numericInput(ns('Main_scatter_thr_X2'), 'X threshold 2',  value=-1, step=0.1) )
                                )
                            ),
                            column(3,
                                fluidRow(
                                column(12, numericInput(ns('Main_scatter_thr_Y1'), 'Y threshold 1', value=1.3, step=0.1) ),
                                column(12, numericInput(ns('Main_scatter_thr_Y2'), 'Y threshold 2', value=0, step=0.1) )
                                )
                            ),
                            column(3, radioButtons(ns("Main_scatter_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                            column(3, radioButtons(ns("Main_scatter_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') ),
                            column(12, h3('\n')),
                        )
                    ),

                    # display options for the filtered genes
                    fluidRow(
                        column(12, h5('\n')),
                        column(6, materialSwitch(ns('show_information'), 'Show the filtered genes information', value=FALSE, status='info')),
                        conditionalPanel(condition = paste0("input['", ns("How_to_filter"), "'] == 'B'"),
                            column(6, materialSwitch(ns('show_threhold_lines'), 'Show the threshold lines', value=FALSE, status='info'))
                        )
                    )
                ),

                ## pathway genes
                conditionalPanel( condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'C'"),

                    # select the pathway
                    fluidRow(
                        column(12, h3('\n')),
                        column(12, helpText("You can select the pathway from the MSigDB hallmark gene sets (for human and mouse) or upload your own gene set in a gmt file.")),
                        column(4, radioButtons(ns("pathway_dataset_select"), "pathways from:", choices = c("HALLMARK (human)", "HALLMARK (mouse)", "Custom"))),
                        column(8,
                            fluidRow(
                                column(12, # when you have to upload a custom gmt
                                    conditionalPanel( condition = paste0("input['", ns("pathway_dataset_select"), "'] == 'Custom'"), 
                                        fileInput(ns("upload_custom_pathway_file"), "Upload a gmt file")
                                    )
                                ),
                                column(12, htmlOutput(ns("select_pathway")))
                            )
                        )
                    ),

                    # display options for the pathway genes
                    fluidRow(
                        column(12, h3('\n')),
                        column(12, materialSwitch(ns('show_information_pathway'), 'Show the genes information', value=FALSE, status='info')),
                        column(6, materialSwitch(ns("Main_scatter_pathway_filter"), "Apply further filtering", value=FALSE, status='info') ),
                        conditionalPanel( condition = paste0("input['", ns("Main_scatter_pathway_filter"), "'] == true"),
                            column(6, materialSwitch(ns('show_threhold_lines_pathway'), 'Show the threshold lines', value=FALSE, status='info')),
                            column(12, 
                                fluidRow(
                                    column(3,
                                        fluidRow(
                                            column(12, numericInput(ns('Main_scatter_pathway_thr_X1'), 'X threshold 1',  value=1, step=0.1) ), 
                                            column(12, numericInput(ns('Main_scatter_pathway_thr_X2'), 'X threshold 2',  value=-1, step=0.1) )
                                        )
                                    ),
                                    column(3,
                                        fluidRow(
                                            column(12, numericInput(ns('Main_scatter_pathway_thr_Y1'), 'Y threshold 1', value=1.3, step=0.1) ), 
                                            column(12, numericInput(ns('Main_scatter_pathway_thr_Y2'), 'Y threshold 2', value=0, step=0.1) )
                                        )
                                    ),
                                    column(3, radioButtons(ns("Main_scatter_pathway_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                                    column(3, radioButtons(ns("Main_scatter_pathway_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') )
                                )
                            )
                        )
                    )

                ),

                ## Custom gene sets
                conditionalPanel( condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'D'"),
                    fluidRow(
                        column(12, h3('\n')),
                        column(12, helpText("You can select the custom gene sets that you have defined in the 'Custom gene sets' module.")),
                        column(12, htmlOutput(ns("Plot_Gene_set_select_geneset"))),
                        column(12, h3('\n')),
                        column(12, materialSwitch(ns('Plot_Gene_setshow_information'), 'Show the genes information', value=FALSE, status='info')),
                        column(6, materialSwitch(ns("Main_scatter_geneset_filter"), "Apply further filtering", value=FALSE, status='info') ),
                        conditionalPanel( condition = paste0("input['", ns("Main_scatter_geneset_filter"), "'] == true"),
                            column(6, materialSwitch(ns('show_threhold_lines_geneset'), 'Show the threshold lines', value=FALSE, status='info')),
                            column(12,
                                fluidRow(
                                    column(3,
                                        fluidRow(
                                            column(12, numericInput(ns('Main_scatter_geneset_thr_X1'), 'X threshold 1',  value=1, step=0.1) ), 
                                            column(12, numericInput(ns('Main_scatter_geneset_thr_X2'), 'X threshold 2',  value=-1, step=0.1) )
                                        )
                                    ),
                                    column(3,
                                        fluidRow(
                                            column(12, numericInput(ns('Main_scatter_geneset_thr_Y1'), 'Y threshold 1', value=1.3, step=0.1) ), 
                                            column(12, numericInput(ns('Main_scatter_geneset_thr_Y2'), 'Y threshold 2', value=0, step=0.1) )
                                        )
                                    ),
                                    column(3, radioButtons(ns("Main_scatter_geneset_thr_X_method"), "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                                    column(3, radioButtons(ns("Main_scatter_geneset_thr_Y_method"), "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') )
                                )
                            )
                        )
                    ),

                    

                ),

                ## common options
                fluidRow(
                    column(12, h5('\n')),        
                    column(6, materialSwitch(ns('show_gene_label'), 'show gene names in the plot', value=FALSE, status='info')),
                    column(6, materialSwitch(ns('show_outliers_bar_plot'), 'Show in a bar plot', value=FALSE, status='info')),
                    column(12, materialSwitch(ns("outlier_gene_colour"), "Change the colour", value=FALSE, status='info')),
                    conditionalPanel(
                    condition = paste0("input['", ns("outlier_gene_colour"), "'] == true"),
                        column(6, colourpicker::colourInput(ns('outlier_gene_colour_id'), 'Positive side:', value='#0000CD')),
                        column(6, colourpicker::colourInput(ns('outlier_gene_colour_id_negative'), 'Negative side:', value='#FF8C00'))
                    )                    
                )
            )
        )
    )
}