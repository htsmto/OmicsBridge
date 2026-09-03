clinical_Survival_ui <- function(ns){
    tagList(
        fluidRow(
            column(12,

                # Inputs and Settings
                box(width=12, status='info', title='Inputs and Settings',
                    fluidRow(
                        column(12, helpText(HTML("Here, you can perform survival analysis based on the gene expression data and the clinical data."))),
                        # Input genes
                        column(3,
                            fluidRow(
                                column(12, htmlOutput(ns('Clinical_Survival_genes'))),
                                column(12, materialSwitch(ns('Clinical_Survival_genes_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                                column(12, 
                                    conditionalPanel( condition = paste0("input['", ns('Clinical_Survival_genes_from_custom_geneset'), "'] == true"),
                                        htmlOutput(ns('Clinical_Survival_genes_from_custom_geneset_select'))
                                    )
                                ),
                                # show the number of the input 
                                column(12, verbatimTextOutput(ns('Clinical_Survival_genes_status')))
                            )
                        ),

                        # Sample split setting
                        column(3,
                            fluidRow(
                                column(12, radioButtons(ns('Clinical_Survival_Split_way'), 'Split the samples by:', choices = c('Median'='A', 'Top 25% vs Bottom 25%'='B', 'Top X% vs Bottom Y%'='D' ,'Custom grouping (No need to enter/set genes)'='C'),selected='A') ),
                                column(12, 
                                    conditionalPanel( condition = paste0("input['", ns('Clinical_Survival_Split_way'), "'] == 'C'"),
                                        fluidRow(
                                            column(6, textAreaInput(ns('Clinical_Survival_Split_Group1'), 'Enter sample names for Group 1 (line by line)') ),
                                            column(6, textAreaInput(ns('Clinical_Survival_Split_Group2'), 'Enter sample names for Group 2 (line by line)') )
                                        )
                                    )
                                ),
                                column(12,
                                    conditionalPanel( condition = paste0("input['", ns('Clinical_Survival_Split_way'), "'] == 'D'"),
                                        fluidRow(
                                            column(6, numericInput(ns('Clinical_Survival_Split_Group1_perc'), 'Top X%:', value=25, min=0, max=100, step=1) ),
                                            column(6, numericInput(ns('Clinical_Survival_Split_Group2_perc'), 'Bottom Y%:', value=25, min=0, max=100, step=1) )
                                        )
                                    )
                                )
                            )
                        ),

                        # Sample filtering setting
                        column(3,
                            fluidRow(
                                column(12, radioButtons(ns('Clinical_Survival_frequency_filter'), 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                                column(12, 
                                    conditionalPanel( condition = paste0("input['", ns('Clinical_Survival_frequency_filter'), "'] == 'B'"),
                                        fluidRow(
                                            column(12, htmlOutput(ns('Clinical_Survival_frequency_filter_selection'))),
                                            column(12, htmlOutput(ns('Clinical_Survival_frequency_filter_selection_category')))
                                        ),  
                                    )
                                ),
                                column(12, verbatimTextOutput(ns('Clinical_Survival_frequency_filter_selection_number'))),
                            )
                        ),

                        # Event type setting
                        column(2,
                            fluidRow(
                                column(12, htmlOutput(ns('Clinical_Survival_choose_score_type'))),
                                column(12, h3('\n')),
                                column(12, actionButton(ns('Clinical_Survival_start'), 'Start the survival analysis',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                            )
                        ),
                        column(1,
                            div(id='help',
                                dropdownButton( 
                                    fluidRow(
                                        column(12, h4(strong("Quick guide"))),
                                        column(12, helpText(
                                        HTML("
                                            0. Select a cohort.<br>
                                            1. Set the input. Enter gene names in the text box or select from the custom gene sets. <br>
                                            2. Select the way to split the samples. <br>
                                            3. Select the type of event for the survival analysis. <br>
                                            4. Click the 'Start the survival analysis' button to run the analysis.<br>
                                            5. A table containing the p value and the hazard ratio for each gene will be displayed in the 'Results' section below.<br>
                                            6. By clicking a gene (row) in the table, the Kaplan-Meier curve and the histogram of the expression distribution will be displayed in the 'Plots' section.<br>                                      
                                        "))
                                        ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                ),
                            ) 
                        )
                    ),

                    # show the status
                    fluidRow(
                        column(8, verbatimTextOutput(ns('Clinical_Survival_input_status')) )
                    )
                )
            )
        ),
        fluidRow(

            # Results table
            column(4, 
                box(width=12, status='warning', title='Results (Hazard Ratios)',
                    fluidRow(
                        column(12, withSpinner(verbatimTextOutput(ns('Clinical_Survival_table_status')), type = 5, color = "#0dc5c1" ) ),
                        column(12, withSpinner(dataTableOutput(ns("Clinical_Survival_table")), type = 5, color = "#0dc5c1" ) ),
                        column(12, h4('')),
                        column(12, downloadButton(ns('Clinical_Survival_table_download'),"Download this table") )
                    )
                )
            ),

            ## Plots
            column(8, 
                box(width=12, status='danger', title='Plots',
                    tabsetPanel(
                        
                        # Kaplan-Meier curve
                        tabPanel("Kaplan-Meier curve",
                            fluidRow(
                                column(12, h4('')),
                                column(10, verbatimTextOutput(ns('Clinical_Survival_plot_error_catch')) ),
                                column(2,
                                dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                    column(6,sliderInput(ns('Clinical_Survival_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(6,sliderInput(ns('Clinical_Survival_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                                    ),
                                    fluidRow(
                                    column(4,sliderInput(ns('Clinical_Survival_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                    column(4,sliderInput(ns('Clinical_Survival_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                    column(4,sliderInput(ns('Clinical_Survival_legend_size'), 'Legend size', min=0.1, max=10, value=4, step=0.1)),
                                    ),
                                    fluidRow(
                                    column(5, colourpicker::colourInput(ns('Clinical_Survival_High_colour'), 'Colour for the "High" group (or Group 1):', value='#ec00ec')),
                                    column(5, colourpicker::colourInput(ns('Clinical_Survival_Low_colour'), 'Colour for the "Low" group (or Group 2):', value='#00aaff')),
                                    ),
                                    circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                                ),
                                column(12, withSpinner(plotOutput(ns("Clinical_Survival_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
                            )
                        
                        ),

                        # expression distribution (histogram)
                        tabPanel("Expression distribution (histogram)",
                            fluidRow(
                                column(12, h4('')),
                                column(10, verbatimTextOutput(ns('Clinical_Survival_plot_distribution_status')) ),
                                column(2,
                                    dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6,sliderInput(ns('Clinical_Survival_distribution_fig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                            column(6,sliderInput(ns('Clinical_Survival_distribution_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                        ),
                                        fluidRow(
                                            column(4,sliderInput(ns('Clinical_Survival_distribution_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                            column(4,sliderInput(ns('Clinical_Survival_distribution_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                            column(4,sliderInput(ns('Clinical_Survival_distribution_graphtitle_size'), 'Graph title size', min=0.1, max=10, value=4, step=0.1)),
                                        ),
                                        fluidRow(
                                            column(4, colourpicker::colourInput(ns('Clinical_Survival_distribution_colour'), 'Colour:', value='#006FED')),
                                            column(4, sliderInput(ns('Clinical_Survival_distribution_bin_num'), 'Bin number', min=10, max=100, value=20, step=1)),
                                            column(4, materialSwitch(ns('Clinical_Survival_distribution_white_background'), 'Use white background', value=FALSE, status = "success"))
                                        ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                                    ),
                                ),
                                column(12, withSpinner(plotOutput(ns("Clinical_Survival_distribution_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ) ),
                            )
                        )
                    )
                )
            )
        )
    )
}