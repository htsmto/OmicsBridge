clinical_Signature_ui <- function(ns){
    fluidRow(
        # Input and settings
        column(12,
            box(width=12, title='Inputs and Settings', collapsible = TRUE, status='info',
                fluidRow(
                    # Input genes
                    column(3, 
                        fluidRow(
                            column(12, htmlOutput(ns('Signature_genes'))),
                            column(12, materialSwitch(ns('Signature_genes_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                            column(12, htmlOutput(ns('Signature_genes_from_custom_geneset_select'))),
                            column(12, verbatimTextOutput(ns('Signature_genes_status')))
                        )
                    ),

                    # Sample filtering
                    column(3,
                        fluidRow(
                            column(12, radioButtons(ns('Signature_filter'), 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                            column(12, htmlOutput(ns('Signature_filter_selection'))),
                            column(12, htmlOutput(ns('Signature_filter_selection_category'))),
                            column(12, verbatimTextOutput(ns('Signature_filter_selection_number')))
                        )
                    ),

                    # Calculation method and start button 
                    column(2, radioButtons(ns('Signature_input_score_type'), 'Calculation method', choices = c('GSVA', 'ssGSEA'), selected='GSVA') ),

                    # action button
                    column(2, 
                        fluidRow(
                            column(12, actionButton(ns('Signature_start'), 'Calculate the signature score', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                            column(12, h5(span('Note: This takes 1~2 minutes depending on the size of the inputted genes. Please be patient.', style="color: red;")) )
                        )
                    ),

                    # Quick guide
                    column(1,
                        div(id='help',
                            dropdownButton( 
                                fluidRow(
                                    column(12, h4(strong("Quick guide"))),
                                    column(12, helpText(
                                        HTML("
                                            0. Select a cohort.<br>
                                            1. Set the input genes. Select a custom geneset or write down the genes list. <br>
                                            2. Choose a method.<br>
                                            3. Click the 'Calculate the signature score'. A result table with the score for each sample will be shown and a Kaplan-Meier curve and a histogram will be automatically generated (in the Survival analysis section and the Distribution section). <br>
                                            4. For the Score comparison part, select a group to compare and click 'Show a Plot'.<br>
                                        "))
                                    ),
                                ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                            ),
                        ) 
                    ),
                    column(12, h4(''))
                ),

                # status
                fluidRow(
                    column(8, verbatimTextOutput(ns('Signature_input_selection_status')))
                )
            )
        ),
    # Results
    column(4, 
        box(width=12, title='Signature Score Results', status='warning',
        fluidRow(
            column(12, verbatimTextOutput(ns('Signature_analysis_status')) ),
            column(12, h2('')),
            column(12, withSpinner(dataTableOutput(ns("Signature_result_table")) , type = 5, color = "#0dc5c1" )),
            column(12, downloadButton(ns('Signature_result_table_download'),"Download this table") )
        )
        )
    ),

    # Plots
    column(8,
        box(width=12, title='Plots', status='danger',
            tabsetPanel(

                # survival analysis
                tabPanel('Survival analysis (Kaplan-Meier Plot)',
                    fluidRow(
                        column(12, h3("")),
                        column(4, 
                            fluidRow(
                                column(12, radioButtons(ns('Signature_Survival_cutoff_method'), 'Split the samples by:', choices = c('Median'='A', 'Top25% vs Bottom 25%'='B', 'Top X% vs Bottom Y%'='C'), selected='A' )),
                                column(12, htmlOutput(ns('Signature_Survival_cutoff_method_note')))
                            )
                        ),
                        column(4, htmlOutput(ns('Signature_Survival_select_event_type'))), # select OS, PFS, etc.
                        column(2, 
                            h3('\n'),
                            dropdownButton( 
                                h4(strong("Plot Options")),
                                fluidRow(
                                    column(6,sliderInput(ns('Signature_Survival_plot_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(6,sliderInput(ns('Signature_Survival_plot_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                                ),
                                fluidRow(
                                    column(6,sliderInput(ns('Signature_Survival_plot_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6,sliderInput(ns('Signature_Survival_plot_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6,sliderInput(ns('Signature_Survival_plot_legend_size'), 'Legend size', min=0.1, max=10, value=4, step=0.1)),
                                ),
                                fluidRow(
                                    column(6, colourpicker::colourInput(ns('Signature_Survival_plot_High_colour'), 'Colour for the "High" group:', value='#ec00ec')),
                                    column(6, colourpicker::colourInput(ns('Signature_Survival_plot_Low_colour'), 'Colour for the "Low" group:', value='#00aaff')),
                                ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(2, h3("")),
                        column(12, verbatimTextOutput(ns('Signature_Survival_detail'))),
                        column(12, withSpinner(plotOutput(ns("Signature_Survival_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" )),
                        column(12, h4(""))
                    )
                ),

                # Score comparison between subtypes
                tabPanel('Score comparison',
                    h4(''),
                    fluidRow(
                        column(6, 
                            fluidRow(
                                column(12, h4('')),
                                column(12, htmlOutput(ns('Signature_subtype_groupBy')) ),
                                column(12, verbatimTextOutput(ns('Signature_subtype_subtype_number')) ),
                                column(12, h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: red;"))),
                                column(12, materialSwitch(ns('Signature_subtype_choose_two_subtypes_only'), 'Compare only two subtypes', value=FALSE, status='info') ),
                                column(12, verbatimTextOutput(ns('Signature_subtype_choose_two_subtypes_only_select_status'))),
                                column(12, htmlOutput(ns('Signature_subtype_choose_two_subtypes_only_select')))
                            )
                        ), 
                        column(4, 
                            h4(''),
                            radioButtons(ns('Signature_subtype_figtype'), 'Plot type', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A')
                        ),
                        column(2,
                            fluidRow(
                                column(12, h3('\n')),
                                column(12, h3('')),
                                column(12, actionButton(ns('Signature_subtype_start'), 'Show a plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                            )
                        )
                    ),
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Signature_subtype_note'))),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6,sliderInput(ns('Signature_subtype_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(6,sliderInput(ns('Signature_subtype_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                                ),
                                fluidRow(
                                    column(6, sliderInput(ns('Signature_subtype_XY_label.font.size'), 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput(ns('Signature_subtype_XY_title.font.size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput(ns('Signature_subtype_title.font.size'), 'Graph title font size', min=0.1, max=10, value=4, step=0.1)),
                                    conditionalPanel( condition = paste0("input['", ns('Signature_subtype_figtype'), "'] == 'C' || input['", ns('Signature_subtype_figtype'), "'] == 'D'"),
                                        column(6, sliderInput(ns('Signature_subtype_dot.size'), 'Dot size (swarm plot)', min=0.01, max=2, value=0.2, step=0.01))
                                    )
                                ),
                                fluidRow(
                                    column(6, materialSwitch(ns('Signature_subtype_white_background'), 'Use white background', value=FALSE, status = "success")),
                                    column(6, materialSwitch(ns('Signature_subtype_rotate_x'), 'Rotate X axis label', value=FALSE, status = "success"))
                                ),
                                fluidRow(
                                    column(6, selectInput(ns('Signature_subtype_select_colour_pallete'), 'Choose a colour palette',  c('None'='None', colour_pallets), selected = 'None')),
                                ),
                                fluidRow(
                                    column(6, materialSwitch(ns('Signature_subtype_use_single_colour'), 'Use a single colour', value=FALSE, status = "success")),
                                    column(6, htmlOutput(ns('Signature_subtype_use_single_colour_ui')))
                                ), circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(12, withSpinner(plotOutput(ns("Signature_subtype_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" )),
                    )
                ),
                tabPanel('Distribution (histogram)',
                    fluidRow(
                        h4(''),
                        column(10, verbatimTextOutput(ns('Signature_score_distribution_status'))), 
                        column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                            column(6,sliderInput(ns('Signature_score_distributionfig.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                            column(6,sliderInput(ns('Signature_score_distribution_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                            ),
                            fluidRow(
                            column(6,sliderInput(ns('Signature_score_distribution_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                            column(6,sliderInput(ns('Signature_score_distribution_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                            ),
                            fluidRow(
                            column(6, colourpicker::colourInput(ns('Signature_score_distribution_colour'), 'Colour:', value='#006FED')),
                            column(6, sliderInput(ns('Signature_score_distribution_bin_num'), 'Bin number', min=10, max=100, value=50, step=1)),
                            column(6, materialSwitch(ns('Signature_score_distribution_white_background'), 'Use white background', value=FALSE, status = "success"))
                            ),
                            circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                        ),
                        column(12, withSpinner(plotOutput(ns("Signature_score_distribution_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                    )
                )
            )
        )
    )
    )   
}