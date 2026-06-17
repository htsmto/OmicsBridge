clinical_Mutation_ui <- function(ns){
    fluidRow(
        # Inputs
        column(12, 
            box(width=12,status='info', title='Inputs and Settings', collapsible=TRUE,
                fluidRow(
                    column(12, helpText(HTML("Here, you can explore the mutation frequency of the genes in your cohort and their association with survival and other gene expressions. "))),
                    
                    # Input genes
                    column(4,
                        fluidRow(
                            column(12, htmlOutput(ns('Clinical_Mutation_genes'))),
                            column(12, materialSwitch(ns('Clinical_Mutation_genes_from_custom_geneset'), 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                            column(12, materialSwitch(ns('Clinical_Mutation_genes_from_the_cohort'), 'Use all the genes from the cohort', value=FALSE, status='info') ),
                            column(12, htmlOutput(ns('Clinical_Mutation_genes_from_custom_geneset_select'))),
                            # show the number of the input 
                            column(12, verbatimTextOutput(ns('Clinical_Mutation_genes_status')))
                        )
                    ),

                    # Sample filtering for mutation frequency analysis
                    column(4, 
                        fluidRow(
                            column(12, radioButtons(ns('Clinical_Mutation_frequency_filter'), 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                            column(12, htmlOutput(ns('Clinical_Mutation_frequency_filter_selection'))),
                            column(12, htmlOutput(ns('Clinical_Mutation_frequency_filter_selection_category'))),
                            column(12, verbatimTextOutput(ns('Clinical_Mutation_frequency_filter_selection_number')))
                        )
                    ),

                    # start button
                    column(2, 
                        fluidRow(column(12, h3(''))),
                        fluidRow(column(12, actionButton(ns('Clinical_Mutation_plot_start'), "Calculate the mutation frequency", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")))
                    ),
                    column(1, h4('')),

                    # help button
                    column(1,
                        div(id='help',
                            dropdownButton( 
                            fluidRow(
                                column(12, h4(strong("Quick guide"))),
                                column(12, helpText(
                                HTML("
                                    0. Select a cohort.<br>
                                    1. Set the input. <br>
                                    2. (Optional) Filter the samples by category if needed.<br>
                                    3. Click the 'Calculate the mutation frequency'. A mutation frequency table and its bar plot will be generated below. <br>
                                    4. By clicking a gene (row) in the table, the Kaplan-Meier curve  will be displayed in the 'Survival analysis' tab in the 'Plots' section.<br>
                                    5. For the 'Gene expression' tab: <br>
                                    - Select a gene from the mutation frequency table. <br>
                                    - Set the input genes <br>
                                    - Click a gene in the table below to compare expression between the mutant and wild-type groups of the gene selected from the mutation frequency table.
                                "))
                                ),
                            ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                            ),
                        ) 
                    )
                    
                ),

                # status
                fluidRow(
                    column(12, h4('')),
                    column(8, verbatimTextOutput(ns('Clinical_Mutation_frequency_plot_status')))
                )
            ),
        ),

        # Results
        column(3, 
            box(width=12, status='warning', title='Results (Mutation Frequency table)', collapsible=TRUE,
            fluidRow(
                column(12, verbatimTextOutput(ns('Clinical_Mutation_frequency_plot_status_table')) ),
                column(12, withSpinner(dataTableOutput(ns("Clinical_Mutation_frequency_table")), type = 5, color = "#0dc5c1" ))
            )
            )
        ),

        # Plots
        column(9, 
            box(width=12, status='danger', title='Plots', collapsible=TRUE,
            tabsetPanel(

                # Frequency Plot
                tabPanel('Frequency Plot',

                    # setting for the frequency plot
                    fluidRow(
                        column(12, h3('')),
                        column(5, radioButtons(ns('Clinical_Mutation_frequency_plot_type'), 'Y axis:', choices=c("Number of patients having mutations"='A', "Percentage of patients hacing mytations"='B'), selected='A') ),
                        column(3, 
                            h5('\n'),
                            numericInput(ns('Clinical_Mutation_frequency_plot_top_X'), 'Show top X frequntly mutated genes:', min=1, value=15, step=1) 
                        ),
                        column(4, h4('') ),
                    ),

                    # Plot for mutation frequency
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Clinical_Mutation_frequency_plot_status_plot')) ),
                        column(2,
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_fig.width'), 'Fig width', min=300, max=3000, value=800, step=10)),
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10)),
                                ),
                                fluidRow(
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_label_size'), 'X label size', min=1, max=15, value=2.5, step=0.1)),
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_title_size'), 'Y lable/title size', min=1, max=15, value=5, step=0.1)),
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_legend_size'), 'Legend font size', min=1, max=15, value=4, step=0.1)),
                                    column(6,sliderInput(ns('Clinical_Mutation_frequency_score_size'), 'Score font size', min=0.1, max=5, value=1, step=0.1)),
                                ),
                                fluidRow(
                                    column(6, colourpicker::colourInput(ns('Clinical_Mutation_frequency_colour_high'), 'Colour of the highest value:', value='#e14b22')),
                                    column(6, colourpicker::colourInput(ns('Clinical_Mutation_frequency_colour_zero'), 'Colour of 0:', value='#ffffff')),
                                    column(6, materialSwitch(ns('Clinical_Mutation_frequency_white_background'), 'Use white background', value=FALSE, status = "success")),
                                    column(6, materialSwitch(ns('Clinical_Mutation_frequency_hide_score'), 'Hide the scores', value=FALSE, status = "success"))
                                ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            ),
                        ),
                        column(12, withSpinner(plotOutput(ns('Clinical_Mutation_frequency_plot'), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                    )
                ),

                # Survival analysis (Kaplan-Meier Plot)
                tabPanel('Survival analysis (Kaplan-Meier Plot)',
                    fluidRow(
                        column(12, h3('') ),
                        column(10, verbatimTextOutput(ns('Clinical_Mutation_Kaplan_plot_status')) ),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                column(6,sliderInput(ns('Clinical_Mutation_Kaplan_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                                column(6,sliderInput(ns('Clinical_Mutation_Kaplan_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                                ),
                                fluidRow(
                                column(6,sliderInput(ns('Clinical_Mutation_Kaplan_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                column(6,sliderInput(ns('Clinical_Mutation_Kaplan_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                column(6,sliderInput(ns('Clinical_Mutation_Kaplan_legend_size'), 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                ),
                                fluidRow(
                                column(6, colourpicker::colourInput(ns('Clinical_Mutation_Kaplan_High_colour'), 'Colour for the "High" group:', value='#ec00ec')),
                                column(6, colourpicker::colourInput(ns('Clinical_Mutation_Kaplan_Low_colour'), 'Colour for the "Low" group:', value='#00aaff')),
                                ),
                                circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(5, htmlOutput(ns('Clinical_Mutation_Kaplan_choose_score_type'))),
                        column(6, h4('')),
                        column(12, withSpinner(plotOutput(ns('Clinical_Mutation_Kaplan_plot'), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                    )
                ),

                # Gene expression compare
                tabPanel('Gene expression compare',
                    fluidRow(
                        column(12, h3('') ),
                        column(12, 

                            # Input for gene expression comparison
                            box(width=12, title='Input and Setting', status='info', collapsible=TRUE,
                                fluidRow(
                                    column(12, helpText(HTML("Here, you can compare the expression of a gene between the mutant and wild-type groups of a specific gene selected from the mutation frequency table. "))),
                                    column(5, 
                                        fluidRow(                                          
                                            column(12, htmlOutput(ns('Clinical_Mutation_Gene_expression_geneInput'))),
                                            column(12, materialSwitch(ns('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset'), 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                            column(12, htmlOutput(ns('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select'))),
                                            column(12, verbatimTextOutput(ns('Clinical_Mutation_Gene_expression_genes_input_status')))
                                            
                                        )
                                    ),
                                    column(1, h4('')),
                                    column(6, radioButtons(ns('Clinical_Mutation_Gene_expression_plot_type'), 'Plot type', c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot' = 'D'), selected='A')),
                                ),
                            ),
                        ),
                        column(3, 

                            # Input gene table
                            box(width=12, title='Input genes table', status='primary', collapsible=TRUE,
                                fluidRow(
                                column(12, verbatimTextOutput(ns("Clinical_Mutation_Gene_expression_geneInput_selecttable_status"))),
                                column(12, withSpinner(dataTableOutput(ns("Clinical_Mutation_Gene_expression_geneInput_selecttable")), type = 5, color = "#0dc5c1" ) )
                                )
                            )
                        ),
                        column(9,

                            # Plot
                            box(width=12, title='Plot for Gene expression comparison', status='danger', collapsible=TRUE,
                                column(10, verbatimTextOutput(ns('Clinical_Mutation_Gene_expression_geneInput_plot_status'))),
                                column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                            column(6,sliderInput(ns('Clinical_Mutation_Gene_expression_fig.width'), 'Fig width', min=300, max=3000, value=600, step=10)),
                                            column(6,sliderInput(ns('Clinical_Mutation_Gene_expression_fig.height'), 'Fig height', min=300, max=3000, value=650, step=10)),
                                        ),                                  
                                        fluidRow(
                                            column(6, sliderInput(ns('Clinical_Mutation_Gene_expression_dot.size'), 'Dot size (swarm plot)', min=0.01, max=3, value=0.1, step=0.01)),
                                            column(6, sliderInput(ns('Clinical_Mutation_Gene_expression_XY_label.font.size'), 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput(ns('Clinical_Mutation_Gene_expression_XY_title.font.size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput(ns('Clinical_Mutation_Gene_expression_legend.font.size'), 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput(ns('Clinical_Mutation_Gene_expression_title.font.size'), 'Graph title font size', min=0.1, max=10, value=4, step=0.1))
                                        ),
                                        fluidRow(
                                            column(6, colourpicker::colourInput(ns('Clinical_Mutation_Gene_expression_col_mut'), 'Colour (mutation)', value='#cd0202')),
                                            column(6, colourpicker::colourInput(ns('Clinical_Mutation_Gene_expression_col_wt'), 'Colour (wild type)', value='#3f48ee')),
                                        ),
                                        fluidRow(
                                            column(6, materialSwitch(ns('Clinical_Mutation_Gene_expression_white_background'), 'Use white background', value=FALSE, status = "success"))
                                        ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                ),
                                column(12, withSpinner(plotOutput(ns('Clinical_Mutation_Gene_expression_geneInput_plot'), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))                                      
                            )
                        )
                    )
                )
            )
            )
        )
    )   
}