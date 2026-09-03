scRNA_UMAP_ui <- function(ns) {
    fluidRow(

        # Plot
        column(8,
            box(width=12, collapsible = TRUE, status = 'danger', title='Plot',
                fluidRow(
                    column(10, verbatimTextOutput(ns('scRNA_UMAP1_status_test'))),
                    column(10, verbatimTextOutput(ns('scRNA_UMAP1_status'))),
                    column(2,
                        dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                            column(6, sliderInput(ns('scRNA_umap1_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10) ),
                            column(6, sliderInput(ns('scRNA_umap1_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10) ),
                            column(6, sliderInput(ns('scRNA_umap1_XY_label'), 'X/Y label size', min=0.1, max=10, value=4, step=0.1) ),
                            column(6, sliderInput(ns('scRNA_umap1_XY_title'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1) ),
                            column(6, sliderInput(ns('scRNA_umap1_legend_size'), 'Legend size', min=0.1, max=10, value=4, step=0.1) ),
                            column(6, sliderInput(ns('scRNA_umap1_graph_title'), 'Graph title size', min=0.1, max=10, value=4, step=0.1) ),
                            column(6, sliderInput(ns('scRNA_umap1_graph_dot_size'), 'Dot size', min=0.01, max=2, value=0.01, step=0.01) )
                        ),
                        fluidRow(
                            column(6, materialSwitch(ns('scRNA_umap1_white_background'), 'Use white background', value=FALSE, status = "success") )
                        ),
                        circle = FALSE, status = "success", icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                        ),
                    ),
                    column(12, withSpinner(plotOutput(ns("scRNA_UMAP1"), brush = ns("scRNA_UMAP1_brush"), width="100%", height="100%"), type=5, color='#0dc5c1') )
                )
            )
        ),

        # Setting
        column(4, 
            box(width=12, collapsible = TRUE, status = 'info', title='Settings',
                fluidRow(
                column(12, h4('')),
                column(10, htmlOutput(ns("scRNA_UMAP1_groupBy"))),
                column(12, verbatimTextOutput(ns('scRNA_UMAP1_groupBy_status'))),
                ),
                fluidRow(
                column(12, materialSwitch(ns("scRNA_UMAP1_highlight_group"), 'Highlight a specific group', status = 'info')),
                column(12, 
                    conditionalPanel(condition = paste0("input['", ns("scRNA_UMAP1_highlight_group"), "'] == true"),
                        fluidRow(
                            column(10, htmlOutput(ns("scRNA_UMAP1_highlight_group_select")))
                        ),
                    # fluidRow(
                    #     column(5, colourpicker::colourInput(ns('scRNA_UMAP1_highlight_group_background'), 'Colour (background)', value='gray') ),
                    #     column(5, colourpicker::colourInput(ns('scRNA_UMAP1_highlight_group_highlight'), 'Colour (highlighted group)', value='red') )
                    # )
                    )
                )
                )
            )
        )

    )
}
