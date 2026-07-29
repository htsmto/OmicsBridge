dataoverview_pca_UI <- function(ns){
    tagList(
        fluidRow(
            column(12, h4('\n'))
        ), 
        fluidRow(
            column(8,
                box(width=12, title=strong('Plot'), collapsible = TRUE, status='danger',
                    fluidRow(
                        column(10, verbatimTextOutput(ns('Data_Overview_PCA_status'))),
                        column(2,
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_fig.width'), label='fig width', min=300, max=3000, value=800, step=10)),
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_fig.height'), label='fig height', min=300, max=3000, value=600, step=10))
                                ),
                                fluidRow(
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_xy.font.size'), label='X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_xy.title.size'), label='X/Y title size', min=0.1, max=10, value=4, step=0.1))
                                ),
                                fluidRow(
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_point_size'), label='Points size', min=0.1, max=5, value=1, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_label_size'), label='Sample label size', min=0.1, max=5, value=1, step=0.1)),
                                    column(6, sliderInput(inputId = ns('Data_Overview_PCA_legend_size'), label='Legend size', min=0.1, max=5, value=4, step=0.1))
                                ),
                                fluidRow(
                                    column(4, materialSwitch(inputId = ns('Data_Overview_PCA_change_colour_by_group'), label='Colour by groups', value=TRUE, status = "success")),
                                    column(4, materialSwitch(inputId = ns('Data_Overview_PCA_label_hide'), label='Hide labels', value=TRUE, status = "success")),
                                ),
                                fluidRow(
                                    column(12, materialSwitch(inputId = ns('Data_Overview_PCA_white_background'), label='Use white background', value=FALSE, status = "success"))
                                ),
                                circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                        ),
                        column(12, withSpinner(plotOutput(ns("Data_Overview_PCA_plot"), width="100%", height="100%", brush = ns("plot_brush_PCA")), type=5, color='#0dc5c1') ),
                        column(10, verbatimTextOutput(ns('Data_Overview_PCA_plot_selected_names')) )
                    )
                )
            ),
            column(4, 
                box(width=12, title=strong("Settings"), collapsible = TRUE,  status='info',
                    fluidRow(
                        column(12, radioButtons(ns('Data_Overview_PCA_plot_type'), 'Plot type', choices = c('PCA'='A', 'tSNE'='B', 'Umap'='C'), selected='A')),
                        conditionalPanel(condition = paste0("input['", ns('Data_Overview_PCA_plot_type'), "'] == 'B'"),
                            column(12, sliderInput(ns('Data_Overview_PCA_tSNE_perplexity'), 'tSNE perplexity', min=1, max=100, value=30, step=1))
                        ),
                        column(12, radioButtons(ns('Data_Overview_PCA_Setting'), 'Sample input setting', choices = c('Use all the samples'='A', 'Define the groups manually'='B'), selected='A')),
                        column(12,
                            conditionalPanel(condition = paste0("input['", ns('Data_Overview_PCA_Setting'), "'] == 'B'"),
                                fluidRow(column(12, htmlOutput(ns("Data_Overview_PCA_Setting_when_difining_groups_manually")))),
                                # fluidRow(
                                #     column(12,
                                #         helpText(HTML("
                                #         Please specify the sample names and their group names that you want to use as the following example.<br>
                                #         Ex.)<br>
                                #         \tSample1_rep1,Group1<br>
                                #         \tSample1_rep2,Group1<br>
                                #         \tSample2_rep1,Group2<br>
                                #         \t...<br>
                                #         "))
                                #     ),
                                #     column(12,
                                #         verbatimTextOutput(ns('Data_Overview_PCA_Setting_group_define_status')),
                                #         textAreaInput(ns("Data_Overview_PCA_Setting_group_define"), "Enter the group description")
                                #     ),
                                #     column(12,
                                #         tags$details(
                                #         tags$summary("List of sample names ▼ (click here)"),  # クリックすると開閉されるタイトル
                                #         div(
                                #             verbatimTextOutput(ns('Data_Overview_PCA_Sample_list'))
                                #         )
                                #         )
                                #     )
                                # ),
                                h3("")
                            ),
                        ),
                        column(12, actionButton(ns('Data_Overview_PCA_Start'), 'Generate a PCA plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                    )
                )
            )
        )

    )
}