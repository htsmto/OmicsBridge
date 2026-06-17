clinical_CompareCohorts_ui <- function(ns){
    fluidRow(
    column(5, 
        box(width=12, title='Inputs and Settings', status='info',
        fluidRow(
            column(7, textAreaInput(ns("Compare_across_cohorts_gene"), 'Enter genes (line by line)')),
            column(12, materialSwitch(ns('Compare_across_cohorts_gene_from_custom_geneset'), 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
            conditionalPanel(
            condition = paste0("input['", ns('Compare_across_cohorts_gene_from_custom_geneset'), "'] == true"),
            column(12, htmlOutput(ns('Compare_across_cohorts_gene_from_custom_geneset_select')))
            )
        ),
        fluidRow(
            column(12, verbatimTextOutput(ns('Compare_across_cohorts_input_status')))
        ),
        fluidRow(
            h4(''),
            column(6, 
            fluidRow(
                column(12, h4(strong('Select one gene below'))),
                column(12, verbatimTextOutput(ns('Compare_across_cohorts_gene_table_status'))),
                column(12, dataTableOutput(ns("Compare_across_cohorts_gene_table"))),
            )
            ),
            column(6, 
            fluidRow(
                column(12, h4(strong('Select cohorts below'))),
                column(12, dataTableOutput(ns("Compare_across_cohorts_cohort_table"))),
            )
            ),
        ),
        ),
    ),
    column(7,
        box(width=12, title='Results and Plots', status='danger',
        tabsetPanel(
            tabPanel('Mutation Frequency',
            fluidRow(
                column(12, h4('')),
                column(12, h4('')),
                column(12, actionButton(ns('Compare_across_cohorts_mut_freq_start'), 'Compare mutation frequencies',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                column(12, h5(span('This takes time depending on how many cohorts you use and the size of each cohort.\nNote: When using all the TCGA, it takes ~30 sec. Please be patient.', style="color: red;")) )
            ),
            fluidRow(
                column(12, h4(strong('Plot'))),
                column(12, verbatimTextOutput(ns('Compare_across_cohorts_mut_freq_plot_status'))),
                column(10, radioButtons(ns('Compare_across_cohorts_mut_freq_plot_type'), "Y axis" , choices=c('Number of patients having mutations' = 'A', 'Percentage of patients hacing mytations' = 'B'), selected='B') ),
                column(2, 
                dropdownButton( h4(strong("Plot Options")),
                    fluidRow(
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                    ),
                    fluidRow(
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_legend_size'), 'legend size', min=0.1, max=10, value=4, step=0.1)),
                    column(6,sliderInput(ns('Compare_across_cohorts_mut_score_size'), 'Score font size', min=0.1, max=5, value=1, step=0.1)),
                    ),
                    fluidRow(
                    column(6, colourpicker::colourInput(ns('Compare_across_cohorts_mut_colour_high'), 'Colour of the highest value:', value='#e14b22')),
                    column(6, colourpicker::colourInput(ns('Compare_across_cohorts_mut_colour_zero'), 'Colour of 0:', value='#ffffff')),
                    column(6, materialSwitch(ns('Compare_across_cohorts_mut_white_background'), 'Use white background', value=FALSE, status = "success")),
                    column(6, materialSwitch(ns('Compare_across_cohorts_mut_hide_score'), 'Hide the scores', value=FALSE, status = "success"))
                    ),
                    circle = FALSE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                )
                ),
                column(12, withSpinner(plotOutput(ns('Compare_across_cohorts_mut_freq_plot'), width="100%", height="100%"), type=5, color='#0dc5c1'))

            ),
            fluidRow(
                column(12, h4('Table')),
                column(12, verbatimTextOutput(ns('Compare_across_cohorts_mut_freq_table_status'))),
                column(12, dataTableOutput(ns('Compare_across_cohorts_mut_freq_table'))),
            ),
            ),
            tabPanel('Gene expression',
            fluidRow(
                column(12, h4('')),
                column(12, h4('')),
                column(12, actionButton(ns('Compare_across_cohorts_gx_start'), 'Compare gene expressions',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                column(12, h5(span('This takes time depending on how many cohorts you use and the size of each cohort.\nNote: When using all the TCGA, it takes ~2 min. Please be patient.', style="color: red;")) )
            ),
            fluidRow(
                column(12, h4(strong('Plot'))),
                column(10, verbatimTextOutput(ns('Compare_across_cohorts_gx_plot_status'))),
                column(2, 
                dropdownButton( h4(strong("Plot Options")),
                    fluidRow(
                    column(6,sliderInput(ns('Compare_across_cohorts_gx_fig.width'), 'Fig width', min=300, max=3000, value=750, step=10)),
                    column(6,sliderInput(ns('Compare_across_cohorts_gx_fig.height'), 'Fig height', min=300, max=3000, value=750, step=10)),
                    ),
                    fluidRow(
                    column(6,sliderInput(ns('Compare_across_cohorts_gx_label_size'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                    column(6,sliderInput(ns('Compare_across_cohorts_gx_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                    ),
                    fluidRow(
                    column(6, materialSwitch(ns('Compare_across_cohorts_gx_white_background'), 'Use white background', value=FALSE, status = "success")),
                    ),
                    circle = FALSE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                )
                ),
                column(12, withSpinner(plotOutput(ns('Compare_across_cohorts_gx_plot'), width="100%", height="100%"), type=5, color='#0dc5c1'))
            )
            )
        )
        )
    )
    )    
}