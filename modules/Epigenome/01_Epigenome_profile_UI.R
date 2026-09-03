Epigenome_profile_UI <- function(ns){
    box(title='Profile Plot', width=12, status='primary', solidHeader = TRUE,
        fluidRow(

            # Input and settings
            column(4,
                box(title='Inputs and Settings', width=12, status='info',
                    fluidRow(
                        column(12, h4(HTML("<u>Select the samples for the profile plot</u>"))),
                        column(10, htmlOutput(ns('Profile_Plot_sample_selection'))),
                        column(2,
                            fluidRow(
                                column(12, h2('') ),
                                column(12, 
                                    div(id='filterin_dropdown',
                                        dropdownButton( 
                                        fluidRow(
                                            column(12, h4(strong("Dataset filtering"))),
                                            column(12, htmlOutput(ns("Profile_Plot_sample_selection_Sequenced_by"))), 
                                            column(12, htmlOutput(ns("Profile_Plot_sample_selection_Experiments"))), 
                                        ), circle = FALSE, status = "info", icon = icon("sliders"), width = "300px",  tooltip = tooltipOptions(title = "Dataset filtering")
                                        )
                                    ) 
                                )
                            )
                        ),
                        column(12, actionButton(ns('reload_database_profile'), 'Refresh list', style="color: #ffffff; background-color: #1C9600; border-color: #2A8708") ),
                        column(12, h5(' ')),
                        column(6, actionButton(ns('Profile_Plot_sample_import'), 'Import the selected sample',style="color: #ffffff; background-color: #33c481; border-color: #04915e") ),
                        column(6, helpText('It takes a while to import the bigwig data. Please be patient after clicking the button.')),
                        column(12, h5('')),
                        column(12, verbatimTextOutput(ns('Profile_Plot_sample_selection_status'))),
                        column(12, h2('')),
                        column(12, h5(strong('List of imported datasets:'))),
                        column(12, helpText('The following samples are used for the profile plot.')),
                        column(12, withSpinner(DT::dataTableOutput(ns("Profile_Plot_imported_sample_table")), type=5, color='#0dc5c1')),
                        column(6, actionButton(ns('Profile_Plot_sample_remove'), 'Remove the selected sample',style="color: #ffffff; background-color:#0e98e8; border-color: #0772b0") ),
                        column(12, h4(HTML("<br><br><u>Plot settings</u>"))),
                        column(12, h2('')),
                        column(12, numericInput(ns('Profile_Plot_extend_length'), 'Extend length (bp)', value=2000, min=0, max=10000, step=10)),
                        column(12, h5(strong('Enter the coordinates below:'))),
                        column(12, helpText(HTML("Please write the genome locus in the format of 'chr:start-end' line by line. <br>For example, 'chr1:1000000-2000000'.")) ),
                        column(12, textAreaInput(ns("Profile_Plot_input_coord"), "", placeholder = "chr1:1000000-2000000\nchr2:1500000-2500000")),
                    ),
                    fluidRow(
                        column(6, actionButton(ns('Profile_Plot_start'), 'Generate a plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                    )
                )
            ),

            # Plot
            column(8,
                box(title='Plot', width=12, status='danger',
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Profile_Plot_status'))),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6, sliderInput(inputId = ns('Profile_Plot_fig.width'), label='Fig width', min=300, max=3000, value=600, step=10)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_fig.height'), label='Fig height (heatmap part)', min=300, max=3000, value=1000, step=10)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_column_font_size'), label='Sample name font size', min=0.1, max=10, value=3, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_legend_font_size'), label='Legend size', min=0.1, max=10, value=3, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_label_size_up'), label='Y label size (upper part)', min=0.1, max=10, value=3, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_label_size_main'), label='X label size (heatmap part)', min=0.1, max=10, value=3, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Profile_Plot_top_annot_height'), label='Fig height (upper part)', min=0.1, max=4, value=0.6, step=0.1))            
                                ),  
                                fluidRow(
                                    column(6, colourpicker::colourInput(ns('Profile_Plot_max_col'), 'Max colour', value='red')),
                                    column(6, colourpicker::colourInput(ns('Profile_Plot_min_col'), 'Min colour', value='white')),
                                    column(6, colourpicker::colourInput(ns('Profile_Plot_line_col'), 'Line colour', value='red'))                               
                                ), circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            ),
                        ),
                        column(12, withSpinner(plotOutput(ns("Profile_Plot_Plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                    )
                )
            )
        )
    )

}