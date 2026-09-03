tools_venndiagram_UI <- function(ns){
    box(width=12, title='Venn Diagram', status='primary',  solidHeader = TRUE,
        fluidRow(

            # Input and settings
            column(4,

                # Input the data
                box(width=12, title='Group Information',collapsible = TRUE, status='info',
                    fluidRow(
                        # show help text and the status
                        column(12, helpText("Input the group names and elements to create a Venn diagram. Then you can plot the Venn diagram and show the overlap elements.")),
                        column(12, verbatimTextOutput(ns("Venn_Diagram_status_input"))),

                        # selection of 2D or 3D Venn diagram
                        column(12, radioButtons(ns('Venn_Diagram_method'), 'Choose a method', choices=c('2D Venn Diagram'='A', '3D Venn Diagram'='B'), selected='A')),

                        # Group1
                        column(12, textInput(ns("Venn_Diagram_Group1_name"), "Group 1 title")),
                        column(12, textAreaInput(ns("Venn_Diagram_Group1_element"), "Group 1 element")),

                        # Group2
                        column(12, textInput(ns("Venn_Diagram_Group2_name"), "Group 2 title")),
                        column(12, textAreaInput(ns("Venn_Diagram_Group2_element"), "Group 2 element")),

                        # Group3
                        column(12, htmlOutput(ns('Venn_Diagram_Group3')))
                    )
                ),

                # show the overlap elements
                box(width=12, title='Overlap Elements',collapsible = TRUE, status='warning',
                    fluidRow(
                        # helptext and status
                        column(12, helpText("You can choose a category to show the overlap elements.")),
                        column(12, verbatimTextOutput(ns("Venn_Diagram_show_overlap_status"))),

                        # 2D Venn diagram
                        column(12, htmlOutput(ns('Venn_Diagram_show_overlap_2D_ui'))),
                        # conditionalPanel(condition = paste0("input['", ns("Venn_Diagram_method"), "'] == 'A'"),  
                        #     column(12, selectInput(ns('Venn_Diagram_show_overlap_2D'), 'Choose a category',  
                        #         c('None'='None', 
                        #         'in Group1 & Group2', 
                        #         'only in Group1', 
                        #         'only in Group2'), selected = 'None')),
                        #     column(12, verbatimTextOutput(ns("Venn_Diagram_show_overlap_2D_list")))
                        # ),

                        # 3D Venn diagram
                        column(12, htmlOutput(ns('Venn_Diagram_show_overlap_3D_ui'))),
                        # conditionalPanel(condition = paste0("input['", ns("Venn_Diagram_method"), "'] == 'B'"),  
                        #     column(12, selectInput(ns('Venn_Diagram_show_overlap_3D'), 'Choose a category',  
                        #         c('None'='None', 
                        #         'in Group1 & Group2 & Group3', 
                        #         'in Group1 & Group2', 
                        #         'in Group2 & Group3', 
                        #         'in Group3 & Group1', 
                        #         'in Group1 & Group2 but not in Group3', 
                        #         'in Group2 & Group3 but not in Group1',
                        #         'in Group3 & Group1 but not in Group2', 
                        #         'Only in Group1',
                        #         'Only in Group2',
                        #         'Only in Group3'), selected = 'None')),
                        #     column(12, verbatimTextOutput(ns("Venn_Diagram_show_overlap_3D_list"))),
                        # ),
                    )
                )
            ),

            # Plot
            column(8,
                box(width=12, title='Plot',collapsible = TRUE, status='danger',
                    fluidRow(
                    column(10, verbatimTextOutput(ns("Venn_Diagram_status_plot"))),
                    column(2, 
                        dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                                column(6, sliderInput(ns('Venn_Diagram_plot.width'), 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(ns('Venn_Diagram_plot.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(ns('Venn_Diagram_plot_label.font.size'), 'Label font size', min=0.01, max=3, value=0.5, step=0.01)),
                                column(6, sliderInput(ns('Venn_Diagram_plot_legend_size'), 'Legend font size', min=0.01, max=3, value=0.5, step=0.01)),
                                column(6, colourpicker::colourInput(ns('Venn_Diagram_plot_col1_colour'), 'Colour for Column-Group 1', value='#AEECF5')),
                                column(6, colourpicker::colourInput(ns('Venn_Diagram_plot_col2_colour'), 'Colour for Column-Group 2', value='#FFF5AB')),
                                conditionalPanel(condition = paste0("input['", ns("Venn_Diagram_method"), "'] == 'B'"),
                                    column(6, colourpicker::colourInput(ns('Venn_Diagram_plot_col3_colour'), 'Colour for Column-Group 3', value='#F0A6F5'))
                                )
                            ),circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                        )
                    ),
                    column(12, withSpinner(plotOutput(ns("Venn_Diagram_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1") )
                    )
                )
            )
        )
    )
}